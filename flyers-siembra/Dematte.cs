using System; using System.Drawing; using System.Drawing.Drawing2D; using System.Drawing.Imaging; using System.Runtime.InteropServices;

// Saca el fondo blanco del logo (des-mezcla el blanco para bordes limpios).
// whiteText: pasa el gris (texto y arco) a blanco, para usarlo sobre fotos o fondos oscuros.
// scale: agranda el original con interpolación bicúbica antes de recortar.
public static class Dematte {
  public static string Run(string inp, string outp) { return Run(inp, outp, true, 1.0); }

  public static string Run(string inp, string outp, bool whiteText, double scale) {
    var src = new Bitmap(inp);
    int w = (int)Math.Round(src.Width * scale), h = (int)Math.Round(src.Height * scale);
    var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
    using (var g = Graphics.FromImage(bmp)) {
      g.InterpolationMode = InterpolationMode.HighQualityBicubic;
      g.PixelOffsetMode = PixelOffsetMode.HighQuality;
      g.SmoothingMode = SmoothingMode.HighQuality;
      g.DrawImage(src, 0, 0, w, h);
    }
    src.Dispose();
    var d = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
    var buf = new byte[d.Stride * h]; Marshal.Copy(d.Scan0, buf, 0, buf.Length);
    int minX = w, minY = h, maxX = 0, maxY = 0;
    for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
      int i = y * d.Stride + x * 4; double B = buf[i], G = buf[i + 1], R = buf[i + 2];
      double mn = Math.Min(R, Math.Min(G, B));
      double a = (255 - mn) / 255.0;
      a = Math.Max(0, Math.Min(1, (a - 0.06) / 0.94));
      if (a <= 0) { buf[i] = 0; buf[i + 1] = 0; buf[i + 2] = 0; buf[i + 3] = 0; continue; }
      double R2 = Clamp((R - (1 - a) * 255) / a), G2 = Clamp((G - (1 - a) * 255) / a), B2 = Clamp((B - (1 - a) * 255) / a);
      double sat = Math.Max(R2, Math.Max(G2, B2)) - Math.Min(R2, Math.Min(G2, B2));
      if (sat < 45) {
        if (whiteText) { R2 = 255; G2 = 255; B2 = 255; a = Math.Min(1, a * 1.3); }
        else { R2 = 0x3A; G2 = 0x3A; B2 = 0x3A; a = Math.Min(1, a * 1.3); }   // gris carbón del logo, opaco
      }
      buf[i] = (byte)B2; buf[i + 1] = (byte)G2; buf[i + 2] = (byte)R2; buf[i + 3] = (byte)(a * 255);
      if (a > 0.15) { if (x < minX) minX = x; if (x > maxX) maxX = x; if (y < minY) minY = y; if (y > maxY) maxY = y; }
    }
    Marshal.Copy(buf, 0, d.Scan0, buf.Length); bmp.UnlockBits(d);
    int pad = (int)(12 * scale);
    int x0 = Math.Max(0, minX - pad), y0 = Math.Max(0, minY - pad);
    var crop = new Rectangle(x0, y0, Math.Min(w, maxX + pad) - x0, Math.Min(h, maxY + pad) - y0);
    using (var o = bmp.Clone(crop, PixelFormat.Format32bppArgb)) o.Save(outp, ImageFormat.Png);
    bmp.Dispose();
    return crop.Width + "x" + crop.Height;
  }
  static double Clamp(double v) { return Math.Max(0, Math.Min(255, v)); }
}
