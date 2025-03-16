package com.bliss.PA.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HelloController {
    @GetMapping("/")
    public String home() {
        return "index";  // This will return index.html from templates folder
    }
}