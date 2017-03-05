**Manuscript** is a simple and to-the-point ruby application for compiling/converting books or reports written in Markdown text (using the [Kramdown](https://kramdown.gettalong.org) syntax) into HTML, PDF (via Latex), EPUB, and MOBI formats. This application strings together the following best-of-breed open-source tools to achieve its goals:

* **Kramdown**: is used to covert markdown into HTML or Latex with a few extensions to support parts, appendices and other non-chapter structures which can be coded as follows:

  ``` text
  
  # Part One
  {: role="part"}
  ```
  
  or
  
  ``` text
  
  # Preface
  {: role="preface"}
  ```
* **Rouge**: is used for syntax highlighting by both the HTML and EPUB compilers.
* **Minted**: is used for syntax highlighting by the Latex compiler.
* **Katex**: is used to render mathematical formulas by the HTML compiler; mathematical formulas are supported natively by Latex. The EPUB is not supported yet; such support can be added using MathJax but that inflates the size of the EPUB book and is for now left to the user to add if needed.
* **MiniMagick**: is used for resizing figure images by the Latex compiler.

## Installation
First clone the application:

``` sh
git clone https://github.com/aalgahmi/manuscript.git
```

This creates a `manuscript` folder which you can rename to something reflective of your book or report:

``` sh
mv manuscript my_first_book
```

Then you:

``` sh
cd my_first_book
```

This application has the following directory structure: 

``` text
.
├── Gemfile
├── Gemfile.lock
├── LICENSE.txt
├── README.md
├── app
│   ├── assets
│   │   ├── fonts
│   │   ├── images
│   │   │   └── cover.png
│   │   ├── layouts
│   │   │   ├── ...
│   │   └── styles
│   │       ├── ...
│   ├── config
│   │   └── application.yml
│   ├── lib
│   │   ├── ...
│   └── test
│       └── ...
├── book
│   ├── 001_dedication.md
│   ├── 002_prologue.md
│   ├── 003_toc.md
│   ├── 004_chp_01.md
│   ├── 005_chp_02.md
│   ├── 006_epilogue.md
│   ├── 007_appendix.md
│   └── figures
│       ├── fig_01_01.png
│       ├── fig_01_02.png
│       └── fig_02_01.png
├── generate
└── output
    └── ...
```

It contains a *dummy* sample book whose contents in the following folders could be replaced by your book's contents:

* `./book` which contains the book's markdown documents and figures. The figures are stored inside the `./book/figures` folder. While there is no restriction on the figure names, the markdown documents must be given names whose alphanumerical order determines their placement in the book. It is, therefore, common to prefix their names with two or three digits so as to put them in order.
* `./app/assets/images` which contains the cover image of the book. If the name of the cover image is not `cover.png`, the new name will need to be specified in the application config file `./app/config/application.yml`. 

The application comes with a default theme which you can change under the `./app/assets` folder.

## Configuration
As mentioned above, the application comes with a configuration file `./app/config/application.yml` that looks like this:

``` yaml
manuscript:
  compiler:
    title: A Sample Book
    author: Abdulmalek Al-Gahmi
    about: A example book demoing the manuscript system for authoring and publishing books
    
    output: manuscript
    
    epub:
      cover_image: images/cover.png
      include_mathjax: false
    
    kramdown:
      html:
        input: GFM
        toc_levels: "1,2"
        math_engine: mathjax
        syntax_highlighter: rouge

      tex:
        max_figure_width: 300px
        input: GFM
        latex_headers: chapter,section,subsection,subsubsection,paragraph,subparagraph
        syntax_highlighter: minted
        syntax_highlighter_opts:
          line_numbers: true
```

In this file you'll need to change the values for `title`, `author`, `about` (description), and `output` (name of the produced book file minus extension) configurations of the book. The other configurations have sensible defaults and need only be changed if different carefully considered values are required.

As mentioned before, if the cover image of your book is not `images/cover.png`, the new name needs to be specified in the `epub: cover_image` configuration. The `epub: include_mathjax` is for future use and is not currently used. 

The `kramdown` configuration contains the Kramdown options for both the HTML and the Latex (tex) compilers. More information about these options can be found in [Kramdown Configuration Options](https://kramdown.gettalong.org/options.html). Notice that the HTML Kramdown options are used by both the HTML and EPUB compilers.

For latex, `MiniMagick` is used to resize the figure images proportional to the `kramdown:tex:max_figure_width` configuration which changes based on the the document class of your latex theme.

## Usage
This application comes with a single simple command: `generate`. This command will compile the book's markdown documents and figure images into the desired target format. The result of such generation is saved under the `./output` folder.

To generate the HTML version of the book, run:

``` sh
./generate html
```

Similarly to generate the PDF version of the book, you first run:
``` sh
./generate latex
```

And then use your [Latex installation](https://www.tug.org/texlive/) to produce the PDF version of the book from the generated `.tex` output file. For instance the following can be used to generate the PDF version of the dummy sample book.

``` sh
cd ./output
pdflatex -shell-escape manuscript.tex
pdflatex -shell-escape manuscript.tex
```

To generate the EPUB3 version of the book you run:

``` sh
./generate epub
```

And from this `.epub` version you can use Amazon's [KindleGen](https://www.amazon.com/gp/feature.html?docId=1000765211) to create the MOBI version of the book:

``` sh
cd ./output/
kindlegen manuscript.epub -o manuscript.mobi
```

## Contribution
Bug reports and pull requests are welcome on GitHub at https://github.com/aalgahmi/manuscript.

## Contact
Abdulmalek Al-Gahmi at [this blog](http://aalgahmi.surge.sh) or [Twitter](https://twitter.com/aalgahmi)

## License
This application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
