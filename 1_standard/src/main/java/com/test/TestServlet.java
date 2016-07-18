package com.test;

import com.google.appengine.api.quota.QuotaServiceFactory;

import java.io.IOException;

import java.io.File;
import java.util.logging.Logger;
import javax.servlet.http.*;
import javax.servlet.ServletContext;


public class TestServlet extends HttpServlet {

	private static final Logger log = Logger.getLogger(TestServlet.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)	throws IOException {
		try {				
          resp.setContentType("text/plain");
          resp.getWriter().println("Hello, world\n");

          ServletContext context = req.getSession().getServletContext();
          resp.getWriter().println("servlet major:minor version: " + context.getMajorVersion() + ":" + context.getMinorVersion());
          resp.getWriter().println("java version " + System.getProperty("java.version"));
		}
		catch (Exception ex ) {
		  resp.getWriter().println("Exception " + ex);
		}

		try {				
		  String fname = "/tmp/somefile.txt";
		  File f = new File(fname);
		  if(f.exists() && !f.isDirectory()) 
		      resp.getWriter().println("Custom Flex runtime detected");
		  else
		  	  resp.getWriter().println("Flex runtime detected");
		}
		catch (Exception ex ) {
			resp.getWriter().println("Exception " + ex);
		}

		resp.getWriter().println(QuotaServiceFactory.getQuotaService().getCpuTimeInMegaCycles());
    resp.getWriter().println("Done ");

	}
}
	

