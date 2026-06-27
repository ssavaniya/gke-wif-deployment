package com.sachin.hello_gke.service;

import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class HelloService {

    public Map<String,String> getMessage() {

        return Map.of(
                "message",
                "Hello from Ingress",

                "environment",
                "dev"
        );
    }
}
