package com.test;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.*;
import java.util.List;
import java.util.TimeZone;
import java.util.logging.Logger;

import javax.servlet.http.*;
import java.io.*;


public class HealthServlet extends HttpServlet {

	private static final Logger log = Logger.getLogger(HealthServlet.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		resp.setContentType("text/plain");
		resp.getWriter().println("ok");
	    
	}
}
	

