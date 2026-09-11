from pypdf import PdfReader
from pathlib import Path

print("================================")
print("      PDF TO TEXT CONVERTER")
print("================================")

pdf_file = input("Enter the PDF file path: ").strip().strip('"')

pdf_path = Path(pdf_file)

if not pdf_path.exists():
    print("❌ PDF file not found!")
    exit()

if pdf_path.suffix.lower() != ".pdf":
    print("❌ Please select a PDF file!")
    exit()

output_path = pdf_path.with_suffix(".txt")

print()
print("Reading PDF...")

reader = PdfReader(str(pdf_path))

text = ""

for page_number, page in enumerate(reader.pages, start=1):
    print(f"Reading page {page_number}...")
    
    page_text = page.extract_text()

    if page_text:
        text += page_text
        text += "\n\n"

output_path.write_text(
    text,
    encoding="utf-8"
)

print()
print("================================")
print("✅ Conversion completed!")
print("================================")
print(f"Output file:")
print(output_path)