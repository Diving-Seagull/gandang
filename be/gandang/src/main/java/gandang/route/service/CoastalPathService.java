package gandang.route.service;

import static gandang.common.exception.ExceptionCode.INVALID_COORDINATES;
import static gandang.common.exception.ExceptionCode.PYTHON_SCRIPT_EXECUTION_ERROR;

import com.fasterxml.jackson.databind.ObjectMapper;
import gandang.common.exception.CustomException;
import gandang.route.dto.CoastalPathResponseDto;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class CoastalPathService {

    @Value("${python.executable}")
    private String pythonExecutable;

    @Value("${python.script.path}")
    private String scriptPath;

    @Value("${python.data.path}")
    private String dataPath;

    @Value("${python.network.path}")
    private String networkPath;

    public CoastalPathResponseDto findPath(double startLat, double startLon, double endLat,
        double endLon) {
        validateCoordinates(startLat, startLon, endLat, endLon);

        try {
            List<String> command = Arrays.asList(
                pythonExecutable,
                scriptPath,
                String.valueOf(startLat),
                String.valueOf(startLon),
                String.valueOf(endLat),
                String.valueOf(endLon),
                dataPath,
                networkPath
            );

            ProcessBuilder processBuilder = new ProcessBuilder(command);
            processBuilder.redirectErrorStream(true);

            // 작업 디렉토리 설정
            processBuilder.directory(new File("/app/python"));

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