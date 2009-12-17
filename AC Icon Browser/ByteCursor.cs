using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Security.Permissions;

namespace Ciper.AC {
    /// <summary>
    /// Summary description for ByteCursor.
    /// </summary>
    public class AC_Text : System.Text.Decoder {
        bool bTextOnly;
        public AC_Text(bool AllowControls) {
            bTextOnly = !AllowControls;
        }

        public virtual int GetCharCount(byte[] data) {
            return GetCharCount(data, 0, data.Length);
        }

        public override int GetCharCount(byte[] data, int index, int count) {
            if (bTextOnly)
                return count;
            int nSize = count;
            while (count-- > 0) {
                byte b = data[index++];
                if ((b & 0x7F) < 0x20) {
                    switch (b) {
                        case 0x0A:
                            nSize++;
                            break;
                        default:
                            nSize--;
                            break;
                    }
                }
            }
            return nSize;
        }

        public virtual char[] GetChars(byte[] data) {
            char[] chars = new char[GetCharCount(data, 0, data.Length)];
            GetChars(data, 0, data.Length, chars, 0);
            return chars;
        }
        public virtual char[] GetChars(byte[] data, int index, int count) {
            char[] chars = new char[GetCharCount(data, index, count)];
            GetChars(data, index, count, chars, 0);
            return chars;
        }
        public override int GetChars(byte[] data, int index, int count, char[] chars, int iChar) {
            byte b;
            int iStart = iChar;
            if (bTextOnly) {
                while (count-- > 0) {
                    b = data[index++];
                    if ((b & 0x7F) < 0x20) {
                        chars[iChar++] = '.';
                    }
                    else {
                        chars[iChar++] = (char)b;
                    }
                }
            }
            else {
                while (count-- > 0) {
                    b = data[index++];
                    if ((b & 0x7F) < 0x20) {
                        switch (b) {
                            case 0x0A:
                                chars[iChar++] = '\r';
                                chars[iChar++] = '\n';
                                break;
                        }
                    }
                    else {
                        chars[iChar++] = (char)b;
                    }
                }
            }
            return iChar - iStart;
        }
    }

    [SecurityPermissionAttribute(SecurityAction.Deny, UnmanagedCode = true)]
    public class ByteCursor : System.IO.Stream {
        byte[] m_data;
        int m_offset;

        public ByteCursor(byte[] data) {
            m_data = data;
            m_offset = 0;
        }

        public bool AtEnd {
            get {
                return m_offset >= m_data.Length;
            }
        }
        public int BytesLeft {
            get {
                return m_data.Length - m_offset;
            }
        }

        public bool Advance(int bytes) {
            m_offset += bytes;
            return AtEnd;
        }

        public int Offset {
            get {
                return m_offset;
            }
            set {
                m_offset = Math.Max(Math.Min((int)value, m_data.Length), 0);
            }
        }

        public string GetString(bool advance) {
            int nLength = ((int)m_data[m_offset + 1] << 8) + m_data[m_offset];
            if (nLength > 0) {
                AC_Text fn = new AC_Text(true);
                char[] chars = fn.GetChars(m_data, m_offset + 2, nLength);
                if (advance) {
                    m_offset += (2 + nLength + 3) & 0x7FFFFFFC;
                }
                return new string(chars);
            }
            if (advance) {
                m_offset += 4;
            }
            return "";
        }

        public int GetBYTE(bool advance) {
            int n = (int)m_data[m_offset];
            if (advance)
                m_offset++;
            return n;
        }

        public int GetWORD(bool advance) {
            int n = (((int)m_data[m_offset + 1]) << 8) + m_data[m_offset];
            if (advance)
                m_offset += 2;
            return n;
        }

        public int GetDWORD(bool advance) {
            int n = ((((((int)m_data[m_offset + 3] << 8) + m_data[m_offset + 2]) << 8) + m_data[m_offset + 1]) << 8) + m_data[m_offset];
            if (advance)
                m_offset += 4;
            return n;
        }
        public int GetBGR3(bool advance) {
            int n = ((((int)m_data[m_offset] << 8) + m_data[m_offset + 1]) << 8) + m_data[m_offset + 2];
            if (advance)
                m_offset += 3;
            return n;
        }

        public int GetRGB3(bool advance) {
            int n = ((((int)m_data[m_offset + 2] << 8) + m_data[m_offset + 1]) << 8) + m_data[m_offset];
            if (advance)
                m_offset += 3;
            return n;
        }

        public int GetBGRA(bool advance) {
            int n = ((((((int)m_data[m_offset] << 8) + m_data[m_offset + 1]) << 8) + m_data[m_offset + 2]) << 8) + m_data[m_offset + 3];
            if (advance)
                m_offset += 4;
            return n;
        }

        public string GetHexByteDump(int nOffset, int nCount) {
            string text = "";
            int iPos = m_offset + nOffset;
            int nEnd = iPos + nCount;
            if (nEnd > m_data.Length)
                nEnd = m_data.Length;
            while (iPos < nEnd) {
                text += m_data[iPos].ToString("X2") + " ";
                iPos++;
            }
            return text;
        }

        public string GetSwapString(bool advance) {
            int nLength = GetWORD(false);
            if (nLength > 0) {
                byte[] tempBytes = new byte[nLength];
                for (int i = 0; i < nLength; i++) {
                    byte b = m_data[m_offset + i + 2];
                    tempBytes[i] = (byte)((b << (byte)4) | (b >> (byte)4));
                }
                AC_Text fn = new AC_Text(true);
                char[] chars = fn.GetChars(tempBytes);
                if (advance) {
                    m_offset += (2 + nLength + 3) & 0x7FFFFFFC;
                }
                return new string(chars);
            }
            if (advance) {
                m_offset += 4;
            }
            return "";
        }

        public string GetText(int nOffset, int nCount) {
            int iPos = m_offset + nOffset;
            int nEnd = iPos + nCount;
            if (nEnd > m_data.Length) {
                nCount = iPos - m_data.Length;
                nEnd = m_data.Length;
            }
            AC_Text fn = new AC_Text(false);
            return new string(fn.GetChars(m_data, iPos, nCount));
        }

        public string GetSwapText(int nOffset, int nCount) {
            int iPos = m_offset + nOffset;
            int nEnd = iPos + nCount;
            if (nEnd > m_data.Length) {
                nCount = iPos - m_data.Length;
                nEnd = m_data.Length;
            }
            byte[] tempBytes = new byte[nCount];
            for (int i = 0; i < nCount; i++) {
                byte b = m_data[iPos + i];
                tempBytes[i] = (byte)((b << (byte)4) | (b >> (byte)4));
            }
            AC_Text fn = new AC_Text(false);
            return new string(fn.GetChars(tempBytes, 0, nCount));
        }

        public System.Drawing.Bitmap Get24BitImage(bool advance) {
            int oStart = m_offset;
            int nXsize = GetDWORD(true);
            int nYsize = GetDWORD(true);
            int nFormat = GetDWORD(true);
            int nLength = GetDWORD(true);

            System.Drawing.Bitmap bmImage = new System.Drawing.Bitmap(nXsize, nYsize, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
            int nSize = nXsize * nYsize;
            int[] data = new int[nSize];
            switch (nFormat) {
                case 21:  // RGBA
                    for (int i = 0; i < nSize; i++) {
                        int pixel = GetDWORD(true);
                        if ((pixel > 0) && (pixel < 0x0FFFFFF))
                            pixel |= unchecked((int)0xFF000000);
                        data[i] = pixel;
                    }
                    break;
                case 20:  // RGB
                    for (int i = 0; i < nSize; i++) {
                        int pixel = GetRGB3(true);
                        if ((pixel > 0) && (pixel < 0x0FFFFFF))
                            pixel |= unchecked((int)0xFF000000);
                        data[i] = pixel;
                    }
                    break;
                default:
                    return null;
            }
            System.Drawing.Imaging.BitmapData bmd = bmImage.LockBits(new System.Drawing.Rectangle(0, 0, nXsize, nYsize), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
            Marshal.Copy(data, 0, bmd.Scan0, nSize);
            bmImage.UnlockBits(bmd);
            if (!advance)
                m_offset = oStart;
            return bmImage;
        }

        public System.Drawing.Bitmap GetRGBImage(bool advance) {
            int oStart = m_offset;
            int nXsize = GetDWORD(true);
            int nYsize = GetDWORD(true);
            int nFormat = GetDWORD(true);
            int nLength = GetDWORD(true);

            System.Drawing.Bitmap bmImage = new System.Drawing.Bitmap(nXsize, nYsize, System.Drawing.Imaging.PixelFormat.Format32bppArgb);

            int nSize = nXsize * nYsize;
            int[] ARGB = new int[nSize];
            int iRed = m_offset;
            int iGreen = m_offset + nSize;
            int iBlue = m_offset + nSize * 2;
            for (int iPixel = 0; iPixel < nSize; iPixel++) {
                int pixel = unchecked((int)0xFF000000) |
                    (((((int)m_data[iRed++]) << 8) + m_data[iGreen++]) << 8) + m_data[iBlue++];
                ARGB[iPixel] = pixel;
            }
            System.Drawing.Imaging.BitmapData bmd = bmImage.LockBits(new System.Drawing.Rectangle(0, 0, nXsize, nYsize), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
            Marshal.Copy(ARGB, 0, bmd.Scan0, ARGB.Length);
            bmImage.UnlockBits(bmd);
            if (advance)
                m_offset += iBlue;
            else
                m_offset = oStart;
            return bmImage;
        }

        public System.Drawing.Bitmap GetIndexedImage(bool advance) {
            int oStart = m_offset;
            int nXsize = GetDWORD(true);
            int nYsize = GetDWORD(true);
            GetDWORD(true);
            GetDWORD(true);
            System.Drawing.Bitmap bmImage = new System.Drawing.Bitmap(nXsize, nYsize, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
            int nSize = nXsize * nYsize;

            System.Drawing.Imaging.BitmapData bmd = bmImage.LockBits(new System.Drawing.Rectangle(0, 0, nXsize, nYsize), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
            Marshal.Copy(m_data, m_offset, bmd.Scan0, nSize);
            bmImage.UnlockBits(bmd);

            if (advance)
                m_offset += nSize;
            else
                m_offset = oStart;
            return bmImage;
        }

        public System.Drawing.Bitmap GetGreyImage(bool advance) {
            int oStart = m_offset;
            int nXsize = GetDWORD(true);
            int nYsize = GetDWORD(true);
            int nFormat = GetDWORD(true);
            int nLength = GetDWORD(true);
            System.Drawing.Bitmap bmImage = new System.Drawing.Bitmap(nXsize, nYsize, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);

            int nSize = nXsize * nYsize;
            byte[] data = new byte[nSize];

            int iData = m_offset; //+1;
            for (int iPixel = 0; iPixel < nSize; iPixel++) {
                data[iPixel] = m_data[iData];
                iData += 2;
            }
            System.Drawing.Imaging.BitmapData bmd = bmImage.LockBits(new System.Drawing.Rectangle(0, 0, nXsize, nYsize), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
            Marshal.Copy(data, 0, bmd.Scan0, nSize);
            bmImage.UnlockBits(bmd);
            if (advance)
                m_offset = iData - 1;
            else
                m_offset = oStart;

            System.Drawing.Imaging.ColorPalette palette = bmImage.Palette;
            for (int iColor = 0; iColor < 256; iColor++) {
                palette.Entries[iColor] = System.Drawing.Color.FromArgb(iColor, iColor, iColor);
            }
            bmImage.Palette = palette;
            return bmImage;
        }

        public override bool CanRead {
            get {
                return true;
            }
        }
        public override bool CanSeek {
            get {
                return true;
            }
        }
        public override bool CanWrite {
            get {
                return false;
            }
        }
        public override void Flush() {
        }
        public override long Length {
            get {
                return this.m_data.Length;
            }
        }
        public override long Position {
            get {
                return m_offset;
            }
            set {
                m_offset = Math.Max(Math.Min((int)value, m_data.Length), 0);
            }
        }
        public override int Read(byte[] data, int offset, int length) {
            if (m_offset + length > m_data.Length)
                length = m_data.Length - m_offset;
            for (int i = 0; i < length; i++) {
                data[offset++] = m_data[m_offset++];
            }
            return length;
        }

        public override long Seek(long pos, System.IO.SeekOrigin origin) {
            switch (origin) {
                case System.IO.SeekOrigin.Current:
                    m_offset += (int)pos;
                    break;
                case System.IO.SeekOrigin.Begin:
                    m_offset = (int)pos;
                    break;
                case System.IO.SeekOrigin.End:
                    m_offset = m_data.Length - (int)pos;
                    break;
            }
            if (m_offset < 0)
                m_offset = 0;
            if (m_offset < m_data.Length)
                m_offset = m_data.Length;
            return m_offset;
        }

        public override void SetLength(long length) {
        }
        public override void Write(byte[] data, int index, int Length) {
        }


    }
}
