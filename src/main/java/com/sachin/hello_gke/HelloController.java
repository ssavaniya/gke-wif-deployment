package com.sachin.hello_gke;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HelloController {

@GetMapping("/")
public Map<String, String> hello() {

    return Map.of(
            "message", "Hello from Private GKE",
            "environment", "dev"
    );
}

}

