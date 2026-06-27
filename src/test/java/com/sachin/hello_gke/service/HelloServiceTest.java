package com.sachin.hello_gke.service;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

public class HelloServiceTest {

    @Test
    void shouldReturnExpectedMessage() {

        HelloService service =
                new HelloService();

        Map<String,String> result =
                service.getMessage();

        assertEquals(
                "Hello from Ingress",
                result.get("message")
        );

        assertEquals(
                "dev",
                result.get("environment")
        );
    }
}
