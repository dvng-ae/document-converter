from flask import Flask, request, send_file, jsonify
from pypdf import PdfReader
import tempfile
import os
import subprocess
import shutil
import time
import urllib.parse
import io

app = Flask(__name__)


# ============================================================
# FIND LIBREOFFICE
# ============================================================

def find_libreoffice():

    path = shutil.which("soffice")

    if path:
        return path

    paths = [
        r"C:\Program Files\LibreOffice\program\soffice.exe",
        r"C:\Program Files (x86)\LibreOffice\program\soffice.exe",
    ]

    for path in paths:
        if os.path.exists(path):
            return path

    return None


# ============================================================
# HOME
# ============================================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "status": "running",
        "message": "Document Converter Python Server is running!",
        "converters": [
            "PDF → Text",
            "Excel → PDF",
            "Word → PDF",
            "PPT → PDF"
        ]
    })


# ============================================================
# PDF → TEXT
# ============================================================

@app.route("/pdf-to-text", methods=["POST"])
def pdf_to_text():

    if "file" not in request.files:
        return jsonify({
            "error": "No file uploaded"
        }), 400

    uploaded_file = request.files["file"]

    if uploaded_file.filename == "":
        return jsonify({
            "error": "No filename"
        }), 400

    print()
    print("================================")
    print("PDF → TEXT")
    print("File:", uploaded_file.filename)
    print("================================")

    try:

        with tempfile.TemporaryDirectory() as temp_dir:

            input_path = os.path.join(
                temp_dir,
                uploaded_file.filename
            )

            output_name = (
                os.path.splitext(
                    uploaded_file.filename
                )[0]
                + ".txt"
            )

            output_path = os.path.join(
                temp_dir,
                output_name
            )

            uploaded_file.save(input_path)

            print("Reading PDF...")

            reader = PdfReader(input_path)

            all_text = []

            for page_number, page in enumerate(
                reader.pages,
                start=1
            ):

                print(
                    f"Reading page {page_number}..."
                )

                text = page.extract_text()

                if text:
                    all_text.append(text)

            final_text = "\n\n".join(
                all_text
            )

            with open(
                output_path,
                "w",
                encoding="utf-8"
            ) as text_file:

                text_file.write(final_text)

            print("PDF → Text completed")

            # FIX: Read into memory so temp_dir can be deleted on Windows
            with open(output_path, "rb") as f:
                return_data = io.BytesIO(f.read())

            return send_file(
                return_data,
                as_attachment=True,
                download_name=output_name,
                mimetype="text/plain"
            )

    except Exception as e:

        print("PDF ERROR:", e)

        return jsonify({
            "error": str(e)
        }), 500


# ============================================================
# EXCEL → PDF
# ============================================================

@app.route("/excel-to-pdf", methods=["POST"])
def excel_to_pdf():

    return office_to_pdf(
        [".xlsx", ".xls"]
    )


# ============================================================
# WORD → PDF
# ============================================================

@app.route("/word-to-pdf", methods=["POST"])
def word_to_pdf():

    return office_to_pdf(
        [".docx", ".doc"]
    )


# ============================================================
# PPT → PDF
# ============================================================

@app.route("/ppt-to-pdf", methods=["POST"])
def ppt_to_pdf():

    return office_to_pdf(
        [".pptx", ".ppt"]
    )


# ============================================================
# OFFICE → PDF
# ============================================================

def office_to_pdf(allowed_extensions):

    if "file" not in request.files:

        return jsonify({
            "error": "No file uploaded"
        }), 400

    uploaded_file = request.files["file"]

    if uploaded_file.filename == "":

        return jsonify({
            "error": "No filename"
        }), 400

    extension = os.path.splitext(
        uploaded_file.filename
    )[1].lower()

    if extension not in allowed_extensions:

        return jsonify({
            "error":
                f"Unsupported file type: {extension}"
        }), 400

    print()
    print("================================")
    print("OFFICE → PDF")
    print("File:", uploaded_file.filename)
    print("Type:", extension)
    print("================================")

    # ========================================================
    # FIND LIBREOFFICE
    # ========================================================

    soffice = find_libreoffice()

    if soffice is None:

        return jsonify({
            "error":
                "LibreOffice was not found."
        }), 500

    print()
    print("LibreOffice:")
    print(soffice)

    try:
        # ====================================================
        # CLEANUP STALE PROCESSES
        # ====================================================
        subprocess.run(["taskkill", "/F", "/IM", "soffice.exe", "/T"], capture_output=True)
        subprocess.run(["taskkill", "/F", "/IM", "soffice.bin", "/T"], capture_output=True)
        time.sleep(0.5)

        # ====================================================
        # CREATE UNIQUE TEMP DIRECTORY
        # ====================================================

        with tempfile.TemporaryDirectory(
            prefix="doc_conv_"
        ) as temp_dir:

            input_path = os.path.abspath(os.path.join(
                temp_dir,
                uploaded_file.filename
            ))

            output_directory = os.path.abspath(os.path.join(
                temp_dir,
                "output"
            ))

            profile_directory = os.path.abspath(os.path.join(
                temp_dir,
                "profile"
            ))

            os.makedirs(output_directory, exist_ok=True)
            os.makedirs(profile_directory, exist_ok=True)

            uploaded_file.save(input_path)

            # =================================================
            # LIBREOFFICE PROFILE URI
            # =================================================
            profile_path = profile_directory.replace("\\", "/")
            profile_uri = "file:///" + urllib.parse.quote(profile_path, safe=":/")

            # =================================================
            # OUTPUT FILE NAME
            # =================================================

            base_name = os.path.splitext(uploaded_file.filename)[0]
            output_name = base_name + ".pdf"
            output_path = os.path.join(output_directory, output_name)

            # =================================================
            # CONVERSION COMMAND
            # =================================================

            command = [
                soffice,
                "--headless",
                "--nologo",
                "--nodefault",
                "--nofirststartwizard",
                f"-env:UserInstallation={profile_uri}",
                "--convert-to", "pdf",
                "--outdir", output_directory,
                input_path
            ]

            soffice_dir = os.path.dirname(soffice)

            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=120,
                cwd=soffice_dir
            )

            if result.returncode != 0:
                raise Exception(f"LibreOffice failed: {result.stderr}")

            if not os.path.exists(output_path):
                raise Exception("PDF was not created.")

            # FIX: Read into memory so temp_dir can be deleted on Windows
            with open(output_path, "rb") as f:
                return_data = io.BytesIO(f.read())

            print("CONVERSION SUCCESSFUL")

            return send_file(
                return_data,
                as_attachment=True,
                download_name=output_name,
                mimetype="application/pdf"
            )

    except Exception as e:
        print("CONVERSION ERROR:", e)
        return jsonify({"error": str(e)}), 500


# ============================================================
# START SERVER
# ============================================================

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
