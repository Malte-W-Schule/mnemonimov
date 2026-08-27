from flask import Flask, request, jsonify, render_template
import tempfile
import os
from asm_to_dot import classify_labels, parse_functions, generate_dot

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/visualize', methods=['POST'])
def visualize():
    data = request.get_json() or {}
    code = data.get('code', '')
    visualize_mode = data.get('visualize_mode', 'basic')
    group_by_bmk = data.get('group_by_bmk', False)
    if not code:
        return jsonify({'error': 'No code provided'}), 400
        
    lines = code.splitlines(keepends=True)
    
    dot_path = None
    try:
        global_vars, functions = classify_labels(lines)
        parsed_functions = parse_functions(lines, global_vars, functions)
        
        # Write DOT to a temporary file
        with tempfile.NamedTemporaryFile(suffix='.dot', delete=False, mode='w', encoding='utf-8') as dot_file:
            dot_path = dot_file.name
            
        generate_dot(global_vars, parsed_functions, dot_path, visualize_mode=visualize_mode, group_by_bmk=group_by_bmk)
        
        # Read the DOT file content
        with open(dot_path, 'r', encoding='utf-8') as f:
            dot_content = f.read()
            
        # Clean up
        if dot_path and os.path.exists(dot_path):
            os.unlink(dot_path)
            
        return jsonify({'dot': dot_content})
    except Exception as e:
        # Cleanup on failure
        if dot_path and os.path.exists(dot_path):
            os.unlink(dot_path)
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
