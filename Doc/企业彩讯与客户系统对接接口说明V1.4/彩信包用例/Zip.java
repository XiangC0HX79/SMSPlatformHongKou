package com.utility;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class Zip {

	public static void main(String[] args) {

		try {
			zip("d:/AAAA/", "d:/bbb.zip");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void zip(String inputFileName, String outputFileName) throws Exception {

		zip(outputFileName, new File(inputFileName));

	}

	private static void zip(String zipFileName, File inputFile) throws Exception {

		ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipFileName));
		zip(out, inputFile, "");
		out.close();
	}

	private static void zip(ZipOutputStream out, File f, String base) throws Exception {

		if (f.isDirectory()) {
			File[] fl = f.listFiles();
			out.putNextEntry(new ZipEntry(base + "/"));
			base = base.length() == 0 ? "" : base + "/";
			for (int i = 0; i < fl.length; i++) {
				zip(out, fl[i], base + fl[i].getName());
			}
		} else {
			out.putNextEntry(new ZipEntry(base));
			FileInputStream in = new FileInputStream(f);
			int b;
			while ((b = in.read()) != -1) {
				out.write(b);
			}
			in.close();
		}
	}
}
