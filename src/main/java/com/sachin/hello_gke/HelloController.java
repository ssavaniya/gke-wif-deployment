package com.sachin.hello_gke;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HelloController {

    @GetMapping("/")
    public Map<String, String> loadBalancer() {
        return Map.of(
                "message", "Hello from Load Balancer",
                "environment", "dev"
        );
    }

    @GetMapping("/ingress")
    public Map<String, String> ingress() {
        return Map.of(
                "message", "Hello from Ingress",
                "environment", "dev"
        );
    }
}
