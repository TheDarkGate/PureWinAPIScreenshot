program PureWinAPIScreenshot;

uses
  windows;

procedure CaptureDesktopImage(filename: string);
var
  bmpHandle: hBitmap;
  bmpPtr: pointer;
  bmpInfo: TBITMAPINFO;
  screenWidth, screenHeight: integer;
  screenDC, bmpDC: hDC;
  fileHandle: file of byte;
  bmpFileHeader: TBITMAPFILEHEADER;
begin
  screenDC := getDC(getDeskTopWindow);
  bmpDC := createCompatibleDC(screenDC);
  screenWidth := getDeviceCaps(screenDC, HORZRES);
  screenHeight := getDeviceCaps(screenDC, VERTRES);
  bmpInfo.bmiHeader.biXPelsPerMeter := round(getDeviceCaps(screenDC, LOGPIXELSX) * 39.37);
  bmpInfo.bmiHeader.biYPelsPerMeter := round(getDeviceCaps(screenDC, LOGPIXELSY) * 39.37);
  zeromemory(@bmpInfo, sizeOf(bmpInfo));
  with bmpInfo.bmiHeader do
  begin
    biSize := sizeOf(TBITMAPINFOHEADER);
    biWidth := screenWidth;
    biheight := screenHeight;
    biplanes := 1;
    biBitCount := 24;
    biCompression := BI_RGB;
  end;
  bmpHandle := createDIBSection(bmpDC, bmpInfo, DIB_RGB_COLORS, bmpPtr, 0, 0);
  selectObject(bmpDC, bmpHandle);
  bitblt(bmpDC, 0, 0, screenWidth, screenHeight, screenDC, 0, 0, SRCCOPY);
  releaseDC(getDeskTopWindow, screenDC);
  assignFile(fileHandle, filename);
  reWrite(fileHandle);

  if screenWidth and 3 <> 0 then
    screenWidth := 4 * ((screenWidth div 4) + 1);

  with bmpFileHeader do
  begin
    bfType := ord('B') + (ord('M') shl 8);
    bfSize := sizeOf(TBITMAPFILEHEADER) + sizeOf(TBITMAPINFOHEADER) + screenWidth * screenHeight * 3;
    bfOffBits := sizeOf(TBITMAPINFOHEADER);
  end;

  blockWrite(fileHandle, bmpFileHeader, sizeOf(TBITMAPFILEHEADER));
  blockWrite(fileHandle, bmpInfo.bmiHeader, sizeOf(TBITMAPINFOHEADER));
  blockWrite(fileHandle, bmpPtr^, screenWidth * screenHeight * 3);
  closeFile(fileHandle);
  deleteObject(bmpHandle);
  deleteDC(bmpDC);
end;

begin
 CaptureDesktopImage('screenshot.bmp');
end.
