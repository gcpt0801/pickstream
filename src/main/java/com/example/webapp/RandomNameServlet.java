package com.example.webapp;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@WebServlet("/api/random-name")
public class RandomNameServlet extends HttpServlet {

    private List<String> names = new ArrayList<>();
    private Random random = new Random();
    private Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        // Initialize with default names
        names.add("Alice Johnson");
        names.add("Bob Smith");
        names.add("Charlie Brown");
        names.add("Diana Prince");
        names.add("Eve Anderson");
        names.add("Frank Miller");
        names.add("Grace Lee");
        names.add("Henry Wilson");
        names.add("Iris Chen");
        names.add("Jack Davis");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (names.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("{\"error\":\"No names available\"}");
            return;
        }
        
        int randomIndex = random.nextInt(names.size());
        String randomName = names.get(randomIndex);
        
        NameResponse nameResponse = new NameResponse(randomName);
        String jsonResponse = gson.toJson(nameResponse);
        
        response.getWriter().write(jsonResponse);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String newName = request.getParameter("name");
        
        if (newName == null || newName.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Name cannot be empty\"}");
            return;
        }
        
        names.add(newName.trim());
        response.getWriter().write("{\"success\":true,\"message\":\"Name added successfully\"}");
    }

    private static class NameResponse {
        private String name;

        public NameResponse(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }
    }
}
