package com.avenfit;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class AvenFitApplication {

    public static void main(String[] args) {
        SpringApplication.run(AvenFitApplication.class, args);
    }

}
