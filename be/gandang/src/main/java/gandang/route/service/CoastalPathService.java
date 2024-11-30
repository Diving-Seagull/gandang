package gandang.route.service;

import static gandang.common.exception.ExceptionCode.CSV_PARSING_ERROR;
import static gandang.common.exception.ExceptionCode.INVALID_COORDINATES;
import static gandang.common.exception.ExceptionCode.PYTHON_SCRIPT_EXECUTION_ERROR;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import gandang.common.exception.CustomException;
import gandang.route.dto.CoastalPathDto;
import gandang.route.dto.CoastalPathResponseDto;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.ResourceUtils;

@Service
@Slf4j
public class CoastalPathService {

    @Value("${python.executable}")
    private String pythonExecutable;

    @Value("${python.script.path}")
    private String scriptPath;

    public CoastalPathResponseDto findPath(double startLat, double startLon, double endLat,
        double endLon) {
        validateCoordinates(startLat, startLon, endLat, endLon);

        try {
            String scriptFullPath = ResourceUtils.getFile("classpath:" + scriptPath)
                .getAbsolutePath();
            String csvPath = ResourceUtils.getFile(
                "classpath:python/jeju_coastal_intersections_sorted.csv").getAbsolutePath();
            String networkPath = ResourceUtils.getFile("classpath:python/jeju_network.pkl")
                .getAbsolutePath();
            String outputDir = ResourceUtils.getFile("classpath:python").getAbsolutePath();

            List<String> command = Arrays.asList(
                pythonExecutable,
                scriptFullPath,
                String.valueOf(startLat),
                String.valueOf(startLon),
                String.valueOf(endLat),
                String.valueOf(endLon),
                csvPath,
                networkPath,
                outputDir  // 결과 파일을 저장할 디렉토리 전달
            );

            ProcessBuilder processBuilder = new ProcessBuilder(command);
            processBuilder.redirectErrorStream(true);

            // 작업 디렉토리 설정
            File pythonDir = ResourceUtils.getFile("classpath:python");
            processBuilder.directory(pythonDir);

            Process process = processBuilder.start();

            // Python 스크립트의 출력을 읽음
            StringBuilder output = new StringBuilder();
            StringBuilder resultJson = new StringBuilder();
            boolean isReadingResult = false;

            try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.equals("RESULT_START")) {
                        isReadingResult = true;
                        continue;
                    }
                    if (line.equals("RESULT_END")) {
                        isReadingResult = false;
                        continue;
                    }

                    if (isReadingResult) {
                        resultJson.append(line);
                    } else {
                        output.append(line).append("\n");
                        log.info(line);
                    }
                }
            }

            int exitCode = process.waitFor();

            if (exitCode != 0) {
                log.error("Python script execution failed. Output: {}", output);
                throw new CustomException(PYTHON_SCRIPT_EXECUTION_ERROR);
            }

            // JSON 파싱
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(resultJson.toString(), CoastalPathResponseDto.class);

        } catch (Exception e) {
            log.error("Error during Python script execution", e);
            throw new CustomException(PYTHON_SCRIPT_EXECUTION_ERROR);
        }
    }

    private void validateCoordinates(double startLat, double startLon, double endLat,
        double endLon) {
        if (!isValidLatitude(startLat) || !isValidLatitude(endLat) ||
            !isValidLongitude(startLon) || !isValidLongitude(endLon)) {
            throw new CustomException(INVALID_COORDINATES);
        }
    }

    private boolean isValidLatitude(double lat) {
        return lat >= -90 && lat <= 90;
    }

    private boolean isValidLongitude(double lon) {
        return lon >= -180 && lon <= 180;
    }
}