package com.nfc4care;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
@ComponentScan(basePackages = {"com.nfc4care.controller", "com.nfc4care.service", "com.nfc4care.repository"})
public class Nfc4CareApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(Nfc4CareApplication.class, args);
    }
} 