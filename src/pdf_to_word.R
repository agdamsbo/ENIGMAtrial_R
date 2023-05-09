

library(reticulate)

py_run_string("from pdf2docx import parse")

# path of pdf file
py_run_string("pdf_file = 'tests/demo_custom.pdf'")

# will create .docx in same path
py_run_string("docx_file = 'tests/demo_custom.docx'")

# Here is where we convert pdf to docx
py_run_string("parse(pdf_file, docx_file, start=0, end=None)")
