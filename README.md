# YAGCP

**Y**et **A**nother **GCP** creator for [WebODM](https://www.opendronemap.org/webodm/)

![Képernyőkép 2022-12-19 171015](https://user-images.githubusercontent.com/89804084/208470295-81555bc6-1bac-4237-9524-dde0944c86ae.png)

## Requirements

- GIT: https://git-scm.com/
- Lazarus: https://www.lazarus-ide.org/

## Build

```terminal
git clone https://github.com/faludiz/CADSys42.git
git clone https://github.com/faludiz/yagcp.git
cd yagcp
build.bat
```

## Usage

- Load images with button or drag-and-drop
- Load GCP coordinates with button or drag-and-drop (txt or csv, with `ID,X,Y,Z` fields)
- Double click on image on left, and select a point from right or from the list at top
- Zoom GCP on the image (left: pan, wheel: zoom in/out), and palce GCP with right click
- And so on
- When it's all done select your CRS and click [GCP list] button and save results to file (ie: gcp_for_webodm.txt)
- Add the saved file to your WebODM project
- Enjoy.
