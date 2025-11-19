package com.example.webapp;

import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.io.StringWriter;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

public class RandomNameServletTest {

    private RandomNameServlet servlet;
    
    @Mock
    private HttpServletRequest request;
    
    @Mock
    private HttpServletResponse response;
    
    private StringWriter responseWriter;
    
    @Before
    public void setUp() throws Exception {
        MockitoAnnotations.initMocks(this);
        servlet = new RandomNameServlet();
        servlet.init();
        
        responseWriter = new StringWriter();
        PrintWriter writer = new PrintWriter(responseWriter);
        when(response.getWriter()).thenReturn(writer);
    }
    
    @Test
    public void testInitializesWith10DefaultNames() throws Exception {
        servlet.doGet(request, response);
        
        String jsonResponse = responseWriter.toString();
        assertNotNull(jsonResponse);
        assertTrue(jsonResponse.contains("\"name\""));
    }
    
    @Test
    public void testDoGetReturnsJsonWithName() throws Exception {
        servlet.doGet(request, response);
        
        verify(response).setContentType("application/json");
        verify(response).setCharacterEncoding("UTF-8");
        
        String jsonResponse = responseWriter.toString();
        assertTrue(jsonResponse.matches("\\{\"name\":\".*\"\\}"));
    }
    
    @Test
    public void testDoPostAddsNewName() throws Exception {
        when(request.getParameter("name")).thenReturn("TestUser");
        
        servlet.doPost(request, response);
        
        verify(response).setContentType("application/json");
        String jsonResponse = responseWriter.toString();
        assertTrue(jsonResponse.contains("\"success\":true"));
        assertTrue(jsonResponse.contains("\"message\":\"Name added successfully\""));
    }
    
    @Test
    public void testDoPostRejectsEmptyName() throws Exception {
        when(request.getParameter("name")).thenReturn("");
        
        servlet.doPost(request, response);
        
        String jsonResponse = responseWriter.toString();
        assertTrue(jsonResponse.contains("\"success\":false"));
        assertTrue(jsonResponse.contains("\"message\":\"Name cannot be empty\""));
    }
    
    @Test
    public void testDoPostRejectsNullName() throws Exception {
        when(request.getParameter("name")).thenReturn(null);
        
        servlet.doPost(request, response);
        
        String jsonResponse = responseWriter.toString();
        assertTrue(jsonResponse.contains("\"success\":false"));
        assertTrue(jsonResponse.contains("\"message\":\"Name cannot be empty\""));
    }
    
    @Test
    public void testRandomNameIsFromTheList() throws Exception {
        // Add a unique name
        when(request.getParameter("name")).thenReturn("UniqueTestName123");
        servlet.doPost(request, response);
        
        // Get random name multiple times
        boolean foundUniqueName = false;
        for (int i = 0; i < 50; i++) {
            responseWriter = new StringWriter();
            PrintWriter writer = new PrintWriter(responseWriter);
            when(response.getWriter()).thenReturn(writer);
            
            servlet.doGet(request, response);
            String jsonResponse = responseWriter.toString();
            
            if (jsonResponse.contains("UniqueTestName123")) {
                foundUniqueName = true;
                break;
            }
        }
        
        assertTrue("Added name should appear in random results", foundUniqueName);
    }
}
