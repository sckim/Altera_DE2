There are two main directories in each Exercise folder:

1. document_files: contains the source files for the lab text and figures. The text files (*.tex)
   are plain ascii files with Latex formatting information. They have been compiled with the 
   miktex version of latex (miktex is freely downloadable from the internet). The sequence of 
   commands used to compile a source file lab_Verilog.tex and produce PDF output is:

   C:> latex lab_Verilog.tex
   C:> dvips -t letter lab_verilog.dvi
 
   This produces a file in PostScript format called lab_verilog.ps. Use Adobe Distiller (or some 
   other ps-to-PDF converter) to convert the postscript file to PDF.

   Each figure is provided in two formats: Framemaker files (*.fm) and PDF files.

   The PDF files can be edited using Adobe Illustrator (or some other program that can import 
   PDF drawings). Once modified the PDF would have to be saved in EPS format, because this is 
   the format of the figures imported into the Latex document.
	
   If you prefer to edit the Framemaker files instead of PDF (the figures were originally created
   using FrameMaker and just saved as PDF files), then directions for converting each Framemaker
   file into encapsulated postscript (EPS) so that it can be included in the Latex document are 
   given at the end of this Readme file.

2. solutions: contains Verilog solutions to each part of each lab. For each 
   solution all files that are needed to compile the code are provided--this includes the Verilog
   source files, Quartus II project file (qpf), and Quartus II settings (qsf) file. The sof
   file is also included for direct download into the DE2 board without compiling the project.


---------------- Directions for converting a Framemaker (*.fm) file into EPS ------------------

If you edit a Framemaker figure, the procedure below can be used to generate a new EPS file, which
is imported into the Latex document.

For each FrameMaker drawing, use File > Save As and select type PDF. Then use Adobe Acrobat to
read this PDF file. In Acrobat, use the Advanced Editing Crop Pages tool to draw a crop region
around the drawing; double-click inside the box you drew to open the Crop Pages dialog and
select "CropBox"  in the Page Display drop-down. Select "Remove White Margins" and then click
"OK" to crop the drawing. Now, use File Save As and specify EPS. These EPS files can be used as
figures inside the Latex document.
