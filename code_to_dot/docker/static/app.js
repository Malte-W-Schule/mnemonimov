import { Graphviz } from "https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/index.js";

// Define custom CodeMirror mode for Mnemonimov ASM dialect
CodeMirror.defineMode("mnemonimov", function() {
    const registers = /^(?:[ats][0-7]|zr)$/i;
    const instructions = /^(?:mov|add|sub|fadd|fsub|fmul|fdiv|cmp|psh|pop|syscall|cea|lde|ste|ret|jmp|jtr|jfs|jtra|jfsa|cal|and|sar|fabs|fcti|fctf|ffma|vffma)$/i;
    const pseudoOps = /^(?:res|emb|def|bmk|sbmk)$/i;
    const types = /^(?:u8t|f32t|u32t|string)$/i;

    return {
        startState: function() {
            return { inString: false };
        },
        token: function(stream, state) {
            // Handle comments
            if (stream.match(/^##?/)) {
                stream.skipToEnd();
                return "comment";
            }

            // Handle strings
            if (state.inString) {
                while (!stream.eol()) {
                    if (stream.next() === '"') {
                        state.inString = false;
                        break;
                    }
                }
                return "string";
            }
            if (stream.peek() === '"') {
                stream.next();
                state.inString = true;
                return "string";
            }

            // Handle numbers
            if (stream.match(/^[0-9]+(?:\.[0-9]+)?/)) {
                return "number";
            }

            // Handle words/identifiers
            let match;
            if (match = stream.match(/^[a-zA-Z_\.\@][a-zA-Z0-9_\.]*/)) {
                const word = match[0].toLowerCase();
                if (instructions.test(word)) {
                    return "builtin"; // Mnemonics (purple)
                }
                if (registers.test(word)) {
                    return "variable-2"; // Registers (red)
                }
                if (pseudoOps.test(word)) {
                    return "keyword"; // Pseudo-ops (blue)
                }
                if (types.test(word)) {
                    return "type"; // types like f32t (yellow/gold)
                }
                // Check if it's a label definition (e.g. label:)
                if (stream.peek() === ':') {
                    return "def";
                }
                return "variable";
            }

            stream.next();
            return null;
        }
    };
});

document.addEventListener("DOMContentLoaded", () => {
    const codeInput = document.getElementById("code-input");
    const btnVisualize = document.getElementById("btn-visualize");
    const spinner = document.getElementById("spinner");
    const placeholderMsg = document.getElementById("placeholder-msg");
    const svgWrapper = document.getElementById("svg-wrapper");
    const fileUpload = document.getElementById("file-upload");
    const dropZone = document.getElementById("drop-zone");
    const chkAdvancedMode = document.getElementById("chk-advanced-mode");
    const chkGroupByBmk = document.getElementById("chk-group-by-bmk");
    
    // Zoom Buttons
    const btnZoomIn = document.getElementById("btn-zoom-in");
    const btnZoomOut = document.getElementById("btn-zoom-out");
    const btnZoomReset = document.getElementById("btn-zoom-reset");
    const btnDownload = document.getElementById("btn-download");
    const btnDownloadSvg = document.getElementById("btn-download-svg");
    
    let panZoomInstance = null;

    // Initialize CodeMirror with our custom "mnemonimov" mode
    const editor = CodeMirror.fromTextArea(codeInput, {
        lineNumbers: true,
        mode: "mnemonimov",
        theme: "material-darker",
        lineWrapping: true,
        tabSize: 4
    });

    // File Drag & Drop
    dropZone.addEventListener("dragover", (e) => {
        e.preventDefault();
        dropZone.classList.add("dragover");
    });

    dropZone.addEventListener("dragleave", () => {
        dropZone.classList.remove("dragover");
    });

    dropZone.addEventListener("drop", (e) => {
        e.preventDefault();
        dropZone.classList.remove("dragover");
        const file = e.dataTransfer.files[0];
        if (file) {
            readFile(file);
        }
    });

    // File Upload Input
    fileUpload.addEventListener("change", (e) => {
        const file = e.target.files[0];
        if (file) {
            readFile(file);
        }
    });

    function readFile(file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            editor.setValue(e.target.result);
        };
        reader.readAsText(file);
    }

    // Visualize Button Click
    btnVisualize.addEventListener("click", async () => {
        const code = editor.getValue().trim();
        if (!code) {
            alert("Please paste or upload some assembly code first.");
            return;
        }

        // Show spinner, disable button
        btnVisualize.disabled = true;
        spinner.style.display = "block";
        
        try {
            const isAdvanced = chkAdvancedMode ? chkAdvancedMode.checked : false;
            const isGroupByBmk = chkGroupByBmk ? chkGroupByBmk.checked : false;
            const response = await fetch("/api/visualize", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ 
                    code: code,
                    visualize_mode: isAdvanced ? "advanced" : "basic",
                    group_by_bmk: isGroupByBmk
                })
            });

            const result = await response.json();

            if (!response.ok) {
                throw new Error(result.error || "Failed to parse assembly code.");
            }

            const dotString = result.dot;
            
            // Render DOT to SVG using Graphviz WASM loaded as ES Module
            const graphviz = await Graphviz.load();
            const svg = graphviz.layout(dotString, "svg", "dot");

            // Hide placeholder, show svg-wrapper
            placeholderMsg.style.display = "none";
            svgWrapper.style.display = "block";
            
            // Clean up previous instance
            if (panZoomInstance) {
                panZoomInstance.destroy();
                panZoomInstance = null;
            }

            // Insert SVG
            svgWrapper.innerHTML = svg;
            
            // Find the svg element inside the wrapper
            const svgElement = svgWrapper.querySelector("svg");
            if (svgElement) {
                // Ensure it takes up full size
                svgElement.setAttribute("width", "100%");
                svgElement.setAttribute("height", "100%");
                
                // Initialize Pan Zoom
                panZoomInstance = svgPanZoom(svgElement, {
                    zoomEnabled: true,
                    controlIconsEnabled: false,
                    fit: true,
                    center: true,
                    minZoom: 0.1,
                    maxZoom: 10
                });
            }
        } catch (error) {
            alert(error.message);
        } finally {
            btnVisualize.disabled = false;
            spinner.style.display = "none";
        }
    });

    // Zoom Controls
    btnZoomIn.addEventListener("click", () => {
        if (panZoomInstance) panZoomInstance.zoomIn();
    });

    // Zoom Controls
    btnZoomOut.addEventListener("click", () => {
        if (panZoomInstance) panZoomInstance.zoomOut();
    });

    btnZoomReset.addEventListener("click", () => {
        if (panZoomInstance) {
            panZoomInstance.resetZoom();
            panZoomInstance.center();
        }
    });

    // Download Button (SVG -> PNG conversion on the client side)
    btnDownload.addEventListener("click", () => {
        const svgElement = svgWrapper.querySelector("svg");
        if (!svgElement) {
            alert("No graph has been rendered yet.");
            return;
        }

        // Get SVG dimensions from viewBox
        const viewBox = svgElement.viewBox.baseVal;
        const width = viewBox.width || svgElement.clientWidth || 800;
        const height = viewBox.height || svgElement.clientHeight || 600;

        const serializer = new XMLSerializer();
        const svgString = serializer.serializeToString(svgElement);
        const svgBlob = new Blob([svgString], { type: "image/svg+xml;charset=utf-8" });
        const URL = window.URL || window.webkitURL || window;
        const blobURL = URL.createObjectURL(svgBlob);
        
        const image = new Image();
        image.onload = () => {
            const canvas = document.createElement("canvas");
            const scale = 2; // High-res scale factor
            canvas.width = width * scale;
            canvas.height = height * scale;
            
            const context = canvas.getContext("2d");
            // Fill background with dark app theme color
            context.fillStyle = "#0b0d13"; 
            context.fillRect(0, 0, canvas.width, canvas.height);
            
            // Draw image on canvas
            context.drawImage(image, 0, 0, canvas.width, canvas.height);
            
            // Trigger PNG download
            const pngURL = canvas.toDataURL("image/png");
            const link = document.createElement("a");
            link.href = pngURL;
            link.download = "mnemonimov_graph.png";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(pngURL);
        };
        image.onerror = (err) => {
            console.error("PNG conversion failed", err);
            alert("Failed to convert to PNG. Falling back to SVG download...");
            
            // Fallback to SVG download
            const link = document.createElement("a");
            link.href = blobURL;
            link.download = "mnemonimov_graph.svg";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        };
        image.src = blobURL;
    });

    // Download Button (SVG Vektor-Download)
    btnDownloadSvg.addEventListener("click", () => {
        const svgElement = svgWrapper.querySelector("svg");
        if (!svgElement) {
            alert("No graph has been rendered yet.");
            return;
        }

        const serializer = new XMLSerializer();
        const svgString = serializer.serializeToString(svgElement);
        const svgBlob = new Blob([svgString], { type: "image/svg+xml;charset=utf-8" });
        const URL = window.URL || window.webkitURL || window;
        const blobURL = URL.createObjectURL(svgBlob);
        
        const link = document.createElement("a");
        link.href = blobURL;
        link.download = "mnemonimov_graph.svg";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(blobURL);
    });
});
