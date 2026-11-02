# Third-party notices

## Mermaid label stylesheet

The stylesheet constant in `scripts/mermaid.js` is adapted from Quarto
1.8.25's `mermaid-init.js`, whose CSS is adapted from mkdocs-material.

Copyright (C) 2022 Posit Software, PBC.
Copyright (c) 2016-2022 Martin Donath.

MIT License

Copyright (c) 2020-2024 Posit Software, PBC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Bootstrap Icons

The three complete SVG data URLs in `scss/_revealjs-menu.scss` (images, gear
and x) are copied from Quarto 1.8.25's
`formats/revealjs/plugins/menu/quarto-menu.css`, which uses Bootstrap Icons.
The box-arrow-up-right drawing in `scss/_html-buttons.scss` is copied from
Quarto 1.10.19's `formats/html/_quarto-rules-link-external.scss`.
The extension uses these SVGs as masks instead of background images.

Copyright (c) 2020-2024 Posit Software, PBC.

Copyright (c) 2019-2024 The Bootstrap Authors.

The MIT licence printed above also applies to these icon paths.
[Upstream licence](https://github.com/twbs/icons/blob/main/LICENSE).

## Catppuccin KSyntaxHighlighting

The templates `syntax/ksyntaxhighlighting.tera` and `syntax/cortado.tera`,
and their generated `.theme` files, derive from
[Catppuccin for KSyntaxHighlighting](https://github.com/catppuccin/ksyntaxhighlighting).
Modified for Constellate and Cortado colour customisations.

Copyright (c) 2021 Catppuccin Org.

The MIT licence printed above also applies to these files. Their existing
copyright and SPDX metadata are retained.
[Upstream template](https://github.com/catppuccin/ksyntaxhighlighting/blob/main/ksyntaxhighlighting.tera).

## Catppuccin logo

`assets/cat-logo.png` is the official
[Catppuccin circle logo](https://github.com/catppuccin/catppuccin/blob/main/assets/logos/exports/1544x1544_circle.png).
Copyright (c) 2021 Catppuccin. The MIT licence above applies to this asset.

## Quarto title templates

The title-slide partials are adapted from Quarto CLI templates, covered by the
Posit copyright and MIT licence above.

## exams2forms browser assets

`assets/exams2forms/webex.css` and `webex.js` derive from
exams2forms 0.2-2 by Achim Zeileis and Reto Stauffer, with package
contributors Dale Barr, Lisa DeBruine, Florian Stampfer and Jonas Tscholl.

Source: https://cran.r-project.org/package=exams2forms
Licence: GNU GPL version 3; see `assets/exams2forms/COPYING`.

Constellate modifications: removed the broad solution-button selector
and configured text labels in the native button table.
