import sys
import re
import subprocess

INSTRUCTIONS = {
    'mov', 'add', 'sub', 'fadd', 'fsub', 'fmul', 'fdiv', 'cmp', 'psh', 'pop',
    'syscall', 'cea', 'lde', 'ste', 'ret', 'jmp', 'jtr', 'jfs', 'jtra', 'jfsa',
    'cal', 'and', 'sar', 'fabs', 'fcti', 'fctf', 'ffma', 'vffma'
}

def classify_labels(lines):
    global_vars = set()
    functions = set()
    current_label = None
    label_lines = {}
    
    for line in lines:
        # Strip comments
        line = line.split('#')[0].strip()
        if not line:
            continue
            
        # Check for def
        def_match = re.match(r'^def\s+([a-zA-Z_][a-zA-Z0-9_\.]*)', line)
        if def_match:
            global_vars.add(def_match.group(1))
            continue
            
        # Check for global label
        label_match = re.match(r'^([a-zA-Z_][a-zA-Z0-9_\.]*):', line)
        if label_match:
            current_label = label_match.group(1)
            label_lines[current_label] = []
            continue
            
        if current_label:
            label_lines[current_label].append(line)
            
    for label, l_lines in label_lines.items():
        is_func = False
        for ll in l_lines:
            parts = re.split(r'[\s,]+', ll)
            if parts and parts[0].lower() in INSTRUCTIONS:
                is_func = True
                break
        if is_func:
            functions.add(label)
        else:
            global_vars.add(label)
            
    return global_vars, functions

def parse_functions(lines, global_vars, functions):
    parsed_functions = {}
    current_func = None
    current_block = None
    current_bmk = None
    
    for line in lines:
        line_raw = line.split('#')[0].strip()
        if not line_raw:
            continue
            
        # Check if line is a bookmark
        bmk_match = re.match(r'^bmk\s+["\']?([^"\']+)["\']?', line_raw)
        if bmk_match:
            current_bmk = bmk_match.group(1)
            continue
            
        # Check if line is a global label
        label_match = re.match(r'^([a-zA-Z_][a-zA-Z0-9_\.]*):', line_raw)
        if label_match:
            label_name = label_match.group(1)
            if label_name in functions:
                current_func = label_name
                current_block = label_name  # The entry block has the same name as the function
                parsed_functions[current_func] = {
                    'bmk': current_bmk,
                    'blocks': {
                        current_block: {
                            'a_regs': set(),
                            't_regs': set(),
                            's_regs': set(),
                            'vars': set(),
                            'calls': set(),
                            'jumps': set(),
                            'falls_through': True,
                            'label': 'Entry',
                            'code': []
                        }
                    },
                    'block_order': [current_block]
                }
                # Process instruction on the same line if any
                line_raw = line_raw[len(label_name)+1:].strip()
                if not line_raw:
                    continue
            else:
                # It's a global variable, ignore it during function parsing
                current_func = None
                current_block = None
                continue
                
        # Check if line is a local label (inside a function)
        local_label_match = re.match(r'^\.([a-zA-Z_][a-zA-Z0-9_]*):', line_raw)
        if local_label_match and current_func:
            local_label = "." + local_label_match.group(1)
            # Create a new block
            current_block = f"{current_func}_{local_label_match.group(1)}"
            parsed_functions[current_func]['blocks'][current_block] = {
                'a_regs': set(),
                't_regs': set(),
                's_regs': set(),
                'vars': set(),
                'calls': set(),
                'jumps': set(),
                'falls_through': True,
                'label': local_label,
                'code': []
            }
            parsed_functions[current_func]['block_order'].append(current_block)
            # Process instruction on the same line if any
            line_raw = line_raw[len(local_label)+1:].strip()
            if not line_raw:
                continue
                
        if current_func and current_block:
            parts = re.split(r'[\s,]+', line_raw)
            instr = parts[0].lower()
            
            if instr in ['emb', 'res', 'def', 'bmk', 'sbmk']:
                continue
                
            block_data = parsed_functions[current_func]['blocks'][current_block]
            block_data['code'].append(line_raw)
            
            # Check for ret
            if instr == 'ret':
                block_data['falls_through'] = False
                continue
                
            # Check for function calls
            if instr == 'cal':
                if len(parts) > 1:
                    called_func = parts[1]
                    block_data['calls'].add(called_func)
                continue
                
            # Check for jumps
            if instr in ['jmp', 'jtr', 'jfs', 'jtra', 'jfsa']:
                if len(parts) > 1:
                    target = parts[1]
                    if target.startswith('.'):
                        target_block = f"{current_func}_{target[1:]}"
                        block_data['jumps'].add(target_block)
                    else:
                        block_data['jumps'].add(target)
                        
                if instr in ['jmp', 'jtra']:
                    block_data['falls_through'] = False
                continue
                
            # Parse operands for registers and variables
            for op in parts[1:]:
                # Registers
                if re.match(r'^a[0-7](\.\.)?$', op):
                    block_data['a_regs'].add(op.replace('..', ''))
                elif re.match(r'^t[0-7](\.\.)?$', op):
                    block_data['t_regs'].add(op.replace('..', ''))
                elif re.match(r'^s[0-7](\.\.)?$', op):
                    block_data['s_regs'].add(op.replace('..', ''))
                else:
                    # Variables
                    clean_op = re.sub(r'[^a-zA-Z0-9_\.]', '', op)
                    base_var = clean_op.split('.')[0]
                    if base_var in global_vars:
                        block_data['vars'].add(clean_op)
                        
    # Post-process for fall-through jumps
    for func_name, func_data in parsed_functions.items():
        order = func_data['block_order']
        for i in range(len(order) - 1):
            curr = order[i]
            nxt = order[i+1]
            if func_data['blocks'][curr]['falls_through']:
                func_data['blocks'][curr]['jumps'].add(nxt)
                
    return parsed_functions

def highlight_line(line):
    import html
    # Color maps matching CodeMirror Theme
    COLORS = {
        'instruction': '#c678dd',
        'register': '#e06c75',
        'pseudo': '#61afef',
        'type': '#e5c07b',
        'number': '#d19a66',
        'string': '#98c379',
        'comment': '#5c6370',
        'default': '#abb2bf'
    }

    REGISTERS = re.compile(r'^(?:[ats][0-7]|zr)$', re.IGNORECASE)
    INSTRUCTIONS = re.compile(r'^(?:mov|add|sub|fadd|fsub|fmul|fdiv|cmp|psh|pop|syscall|cea|lde|ste|ret|jmp|jtr|jfs|jtra|jfsa|cal|and|sar|fabs|fcti|fctf|ffma|vffma)$', re.IGNORECASE)
    PSEUDO_OPS = re.compile(r'^(?:res|emb|def|bmk|sbmk)$', re.IGNORECASE)
    TYPES = re.compile(r'^(?:u8t|f32t|u32t|string)$', re.IGNORECASE)

    token_specification = [
        ('COMMENT',     r'#.*'),
        ('STRING',      r'"[^"]*"|\'[^\']*\''),
        ('NUMBER',      r'\b\d+(?:\.\d+)?\b'),
        ('WORD',        r'[a-zA-Z_\.\@][a-zA-Z0-9_\.]*'),
        ('PUNCTUATION', r'[,:\(\)\-\+\$\#]'),
        ('SPACE',       r'\s+'),
        ('MISMATCH',    r'.'),
    ]
    
    tok_regex = '|'.join(f'(?P<{name}>{pattern})' for name, pattern in token_specification)
    
    highlighted = []
    
    for mo in re.finditer(tok_regex, line):
        kind = mo.lastgroup
        value = mo.group(kind)
        
        escaped_val = html.escape(value)
        
        if kind == 'WORD':
            if INSTRUCTIONS.match(value):
                highlighted.append(f'<font color="{COLORS["instruction"]}">{escaped_val}</font>')
            elif REGISTERS.match(value):
                highlighted.append(f'<font color="{COLORS["register"]}">{escaped_val}</font>')
            elif PSEUDO_OPS.match(value):
                highlighted.append(f'<font color="{COLORS["pseudo"]}">{escaped_val}</font>')
            elif TYPES.match(value):
                highlighted.append(f'<font color="{COLORS["type"]}">{escaped_val}</font>')
            else:
                highlighted.append(f'<font color="{COLORS["default"]}">{escaped_val}</font>')
        elif kind == 'STRING':
            highlighted.append(f'<font color="{COLORS["string"]}">{escaped_val}</font>')
        elif kind == 'NUMBER':
            highlighted.append(f'<font color="{COLORS["number"]}">{escaped_val}</font>')
        elif kind == 'COMMENT':
            highlighted.append(f'<font color="{COLORS["comment"]}">{escaped_val}</font>')
        elif kind == 'SPACE':
            highlighted.append(escaped_val)
        else:
            highlighted.append(f'<font color="{COLORS["default"]}">{escaped_val}</font>')
            
    return "".join(highlighted)

def write_func_subgraph(f, func_name, func_data, func_colors, visualize_mode, indent="    "):
    func_color = func_colors.get(func_name, "#ffffff")
    f.write(f'{indent}subgraph "cluster_{func_name}" {{\n')
    f.write(f'{indent}    label="{func_name}";\n')
    f.write(f'{indent}    color="{func_color}";\n')
    f.write(f'{indent}    style=solid;\n')
    f.write(f'{indent}    penwidth=2.5;\n')
    f.write(f'{indent}    fontname="Arial Bold";\n')
    f.write(f'{indent}    fontsize=14;\n')
    f.write(f'{indent}    fontcolor="#000000";\n')
    
    for block_name, block in func_data['blocks'].items():
        a_regs = ', '.join(sorted(block['a_regs'])) or '-'
        t_regs = ', '.join(sorted(block['t_regs'])) or '-'
        s_regs = ', '.join(sorted(block['s_regs'])) or '-'
        vars_acc = ', '.join(sorted(block['vars'])) or '-'
        
        block_label = block.get('label', 'Entry')
        if block_label == 'Entry':
            block_label = func_name
        
        if visualize_mode == 'advanced':
            code_lines = block.get('code', [])
            if code_lines:
                formatted_code = "".join(f'<font face="Courier" point-size="10">{highlight_line(line)}</font><br align="left"/>' for line in code_lines)
            else:
                formatted_code = '<font face="Courier" point-size="10">-</font><br align="left"/>'
                
            table = f'''<
            <table border="0" cellborder="1" cellspacing="0" cellpadding="4">
                <tr><td bgcolor="{func_color}" colspan="2"><b><font color="#000000">{block_label}</font></b></td></tr>
                <tr><td align="left">A-Regs</td><td align="left">{a_regs}</td></tr>
                <tr><td align="left">T-Regs</td><td align="left">{t_regs}</td></tr>
                <tr><td align="left">S-Regs</td><td align="left">{s_regs}</td></tr>
                <tr><td align="left">Vars</td><td align="left">{vars_acc}</td></tr>
                <tr><td bgcolor="#1e222b" colspan="2" align="left"><b><font color="#abb2bf">Instructions</font></b></td></tr>
                <tr><td colspan="2" align="left" balign="left">{formatted_code}</td></tr>
            </table>
            >'''
        else:
            table = f'''<
            <table border="0" cellborder="1" cellspacing="0" cellpadding="4">
                <tr><td bgcolor="{func_color}" colspan="2"><b><font color="#000000">{block_label}</font></b></td></tr>
                <tr><td align="left">A-Regs</td><td align="left">{a_regs}</td></tr>
                <tr><td align="left">T-Regs</td><td align="left">{t_regs}</td></tr>
                <tr><td align="left">S-Regs</td><td align="left">{s_regs}</td></tr>
                <tr><td align="left">Vars</td><td align="left">{vars_acc}</td></tr>
            </table>
            >'''
        f.write(f'{indent}    "{block_name}" [label={table}];\n')
        
    f.write(f'{indent}}}\n')

def generate_dot(global_vars, parsed_functions, output_path, visualize_mode='basic', group_by_bmk=False):
    # Harmonies neon/pastel colors for functions to distinguish them
    COLORS = [
        "#00d2ff", # Cyan
        "#00f5d4", # Mint
        "#7b2cbf", # Purple
        "#ff007f", # Rose
        "#ff9f1c", # Orange
        "#9ef01a", # Lime Green
        "#ff0054", # Red-pink
        "#3a86c8", # Muted Blue
        "#ff007f", # Hot Pink
        "#e5c07b"  # Gold
    ]
    
    # Sort functions for deterministic color assignment
    sorted_funcs = sorted(list(parsed_functions.keys()))
    func_colors = {func: COLORS[i % len(COLORS)] for i, func in enumerate(sorted_funcs)}

    with open(output_path, 'w') as f:
        f.write('digraph G {\n')
        f.write('    node [shape=none, fontname="Arial"];\n')
        f.write('    rankdir=LR;\n')
        f.write('    nodesep=0.5;\n')
        f.write('    ranksep=1.0;\n')
        
        # 1. Global Variables Node
        if global_vars:
            vars_rows = "".join(f'<tr><td align="left">{v}</td></tr>' for v in sorted(global_vars))
            table = f'''<
            <table border="0" cellborder="1" cellspacing="0" cellpadding="4">
                <tr><td bgcolor="#abb2bf" color="#abb2bf"><b><font color="#000000">Global Variables</font></b></td></tr>
                {vars_rows}
            </table>
            >'''
            f.write(f'    "GlobalVariables" [label={table}];\n\n')
            
        # 2. Subgraphs for Functions (grouped by bookmark if requested)
        if group_by_bmk:
            bmk_groups = {}
            no_bmk_funcs = []
            for func_name, func_data in parsed_functions.items():
                bmk = func_data.get('bmk')
                if bmk:
                    if bmk not in bmk_groups:
                        bmk_groups[bmk] = []
                    bmk_groups[bmk].append((func_name, func_data))
                else:
                    no_bmk_funcs.append((func_name, func_data))
                    
            bmk_counter = 0
            for bmk_name, funcs in bmk_groups.items():
                bmk_id = f"bmk_{bmk_counter}"
                bmk_counter += 1
                f.write(f'    subgraph "cluster_{bmk_id}" {{\n')
                f.write(f'        label="{bmk_name}";\n')
                f.write('        color="#abb2bf";\n')
                f.write('        style=dashed;\n')
                f.write('        penwidth=1.5;\n')
                f.write('        fontname="Arial Bold";\n')
                f.write('        fontsize=16;\n')
                f.write('        fontcolor="#abb2bf";\n')
                
                for func_name, func_data in funcs:
                    write_func_subgraph(f, func_name, func_data, func_colors, visualize_mode, indent="        ")
                    
                f.write('    }\n\n')
                
            for func_name, func_data in no_bmk_funcs:
                write_func_subgraph(f, func_name, func_data, func_colors, visualize_mode, indent="    ")
        else:
            for func_name, func_data in parsed_functions.items():
                write_func_subgraph(f, func_name, func_data, func_colors, visualize_mode, indent="    ")
            
        # 3. Edges (Jumps and Calls)
        for func_name, func_data in parsed_functions.items():
            func_color = func_colors.get(func_name, "#ffffff")
            for block_name, block in func_data['blocks'].items():
                # Jumps (Internal control flow)
                for jump in block['jumps']:
                    if jump in parsed_functions:
                        f.write(f'    "{block_name}" -> "{jump}" [color="#ff4757", style=dashed, penwidth=1.5];\n')
                    else:
                        f.write(f'    "{block_name}" -> "{jump}" [color="#ff4757", penwidth=1.5];\n')
                        
                # Calls (External arrows - colored matching the caller function!)
                for call in block['calls']:
                    if call in parsed_functions:
                        f.write(f'    "{block_name}" -> "{call}" [color="{func_color}", penwidth=2.5];\n')
                    else:
                        f.write(f'    "{block_name}" -> "{call}" [color="{func_color}", style=dotted, penwidth=2.0];\n')
                        
        f.write('}\n')

if __name__ == "__main__":
    if len(sys.argv) not in (3, 4, 5):
        print("Usage: python asm_to_dot.py <input.asm> <output.dot> [basic|advanced] [true|false]")
        sys.exit(1)
        
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    visualize_mode = sys.argv[3] if len(sys.argv) >= 4 else 'basic'
    group_by_bmk = (sys.argv[4].lower() == 'true') if len(sys.argv) == 5 else False
    
    with open(input_file, 'r') as f:
        lines = f.readlines()
        
    global_vars, functions = classify_labels(lines)
    parsed_functions = parse_functions(lines, global_vars, functions)
    generate_dot(global_vars, parsed_functions, output_file, visualize_mode=visualize_mode, group_by_bmk=group_by_bmk)
    print(f"Generated {output_file} (mode: {visualize_mode}, group_by_bmk: {group_by_bmk})")
    
    # Compile to PNG
    try:
        png_path = output_file.rsplit('.', 1)[0] + '.png'
        subprocess.run(['dot', '-Tpng', output_file, '-o', png_path], check=True)
        print(f"Generated PNG: {png_path}")
    except Exception as e:
        print(f"Could not generate PNG automatically: {e}")
