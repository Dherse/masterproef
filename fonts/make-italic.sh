#!/usr/bin/fontforge
FONT_NAME = "UGentPannoText"
VARIANTS = ["SemiBold", "SemiLight", "Medium", "Normal"]
i = 0

while (i < SizeOf(VARIANTS))
  FILE_NAME = FONT_NAME + "-" + VARIANTS[i] + ".ttf"
  FILE_NAME_ITALIC = FONT_NAME + "-" + VARIANTS[i] + "Italic.ttf"
  Print(FILE_NAME)
  Open(FILE_NAME)
  SelectAll()
  Skew(15)
  Generate(FILE_NAME_ITALIC)
  i = i + 1
endloop