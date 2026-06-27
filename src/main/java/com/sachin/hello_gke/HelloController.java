package com.sachin.hello_gke;

import com.sachin.hello_gke.service.HelloService;

import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
public class HelloController {

    private final HelloService helloService;

    public HelloController(
            HelloService helloService
    ) {
        this.helloService =
                helloService;
    }

    @GetMapping("/")
    public Map<String,String> hello() {

        return helloService
                .getMessage();
    }
}
