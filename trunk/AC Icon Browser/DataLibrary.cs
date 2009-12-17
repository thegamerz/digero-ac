using System;
using System.IO;

namespace Ciper.AC
{
	/// <summary>
	/// Summary description for DataLibrary.
	/// </summary>
	/// 
	
	public class DataLibrary 
	{
		System.IO.FileStream          m_Library;
		System.IO.BinaryReader        m_Read;
		System.Collections.SortedList m_FileTable;
		bool                          m_Preload;

		public class FileEntry
		{
			int m_fileid;
			int m_offset;
			int m_length;
			int m_unknown1;
			int m_unknown2;
			int m_unknown3;
			byte[] m_data;
			public FileEntry(int Index, int Offset, int Length)
			{
				m_fileid = Index;
				m_offset = Offset;
				m_length = Length;
				m_data   = null;
			}

			public FileEntry(ref ByteCursor csr)
			{
				m_unknown1 = csr.GetDWORD(true);
				m_fileid = csr.GetDWORD(true);
				m_offset = csr.GetDWORD(true);
				m_length = csr.GetDWORD(true);
				m_unknown2 = csr.GetDWORD(true);
				m_unknown3 = csr.GetDWORD(true);
			}

			public int Index  { get { return m_fileid; } }
			public int Offset { get { return m_offset; } }
			public int Length { get { return m_length; } }
		}

		private FileEntry FindFileEntry(int nID)
		{
			int nOffset = m_Read.ReadInt32();
			while (nOffset != 0)
			{
				ByteCursor csr = LoadDir(nOffset);
				csr.Position = 248;
				int nCount   = csr.GetDWORD(true);
				int iFile    = 0;
				while (iFile < nCount)
				{
					int Index = csr.GetDWORD(false);
					FileEntry e = new FileEntry(ref csr);
					if (Index > nID)  break;
					if (Index == nID) return new FileEntry(ref csr);
					iFile++;
					csr.Advance(20);
				}
				csr.Position = 0;
				if (csr.GetDWORD(false) == 0) return null;
				csr.Position = iFile * 4;
				nOffset = csr.GetDWORD(false);
			}
			return null;
		}

		private void LoadPortalDir(int offset)
		{
			ByteCursor csr = this.LoadDir(offset);

			csr.Position = 248;
			int nCount   = csr.GetDWORD(true);

			for (int i=0;i < nCount; i++)
			{
				FileEntry e = new FileEntry(ref csr);
				m_FileTable[e.Index] = e;
			}
			csr.Position = 0;
			if (csr.GetDWORD(false) == 0) return;
			for (int i=0;i <= nCount; i++)
			{
				LoadPortalDir(csr.GetDWORD(true));
			}
			if (csr.GetDWORD(true)!=0)
			{
				bool bStopHere = true;
			}
		}

		public DataLibrary(string sFilename, bool Preload)
		{
			m_Library = new System.IO.FileStream( sFilename
				, System.IO.FileMode.Open
				, System.IO.FileAccess.Read
				, System.IO.FileShare.ReadWrite);

			m_Read = new System.IO.BinaryReader(m_Library);

			if (m_Preload = Preload)
			{
				m_FileTable = new System.Collections.SortedList();
				m_Library.Position =  0x0160; //was 0x0148;
				LoadPortalDir(m_Read.ReadInt32());
			}
			else
			{
				m_FileTable = null;
			}
		}

		public FileEntry get_FileEntry(int nID)
		{
			if (m_Preload)  
			{
				return (FileEntry) m_FileTable[nID];
			}
			return FindFileEntry(nID);
		}

		public ByteCursor LoadFile(FileEntry file)
		{
			m_Library.Position = file.Offset;
			int oNext  = m_Read.ReadInt32();
			if (file.Index != m_Read.ReadInt32()) return null;
			int nLength     = file.Length;
			int nOffset     = 0;
			int nBlockSize  = 1016;
			byte[] data = new byte[nLength];
			while (nLength > 0)
			{
				if (nBlockSize > nLength) nBlockSize = nLength;
				m_Read.Read(data,nOffset,nBlockSize);
				nLength -= nBlockSize;
				nOffset += nBlockSize;
				m_Read.BaseStream.Position = oNext;
				nBlockSize = 1020;
				oNext  =m_Read.ReadInt32();
			}
			return new ByteCursor(data);
		}

		public ByteCursor LoadDir(int offset)
		{
			m_Read.BaseStream.Position = offset;
			int nRoot = m_Read.ReadInt32();
			return  new ByteCursor(m_Read.ReadBytes(62*4+4+62*20+2000));
		}

		public System.Collections.ICollection FileEntries
		{
			get { return m_FileTable.Values; }
		}

	}
}
