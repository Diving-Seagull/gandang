package gandang.common.utils;

import static gandang.common.exception.ExceptionCode.LANGUAGE_DETECTION_FAILED;

import com.google.cloud.translate.Detection;
import com.google.cloud.translate.Translate;
import com.google.cloud.translate.TranslateOptions;
import com.google.cloud.translate.Translation;
import com.google.common.collect.ImmutableList;
import gandang.common.exception.CustomException;
import gandang.common.utils.dto.DetectLanguageResponseDto;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import javax.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.text.StringEscapeUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class TranslationUtil {

    @Value("${google.api.key}")
    private String apiKey;

    private Translate translate;
    private final Map<String, String> translationCache = new ConcurrentHashMap<>();

    @PostConstruct
    public void init() {
        this.translate = TranslateOptions.newBuilder()
            .setApiKey(apiKey)
            .build()
            .getService();
    }

    public String translateText(String text, String targetLanguageCode) {
        DetectLanguageResponseDto detectedLanguage = detectLanguage(text);

        if (detectedLanguage.getLanguageCode().equals(targetLanguageCode)) {
            return text;
        }

        String cacheKey =
            text + "_" + detectedLanguage.getLanguageCode() + "_" + targetLanguageCode;
        try {
            return translationCache.computeIfAbsent(cacheKey, k -> {
                try {
                    Translation translation = translate.translate(
                        text,
                        Translate.TranslateOption.sourceLanguage(
                            detectedLanguage.getLanguageCode()),
                        Translate.TranslateOption.targetLanguage(targetLanguageCode)
                    );
                    String translatedText = translation.getTranslatedText();
                    return decodeHtmlEntities(translatedText); // HTML 엔티티 디코딩 추가
                } catch (Exception e) {
                    log.error("Translation failed for text: '{}' from {} to {}.", text,
                        detectedLanguage.getLanguageCode(), targetLanguageCode, e);
                    return text; // 번역 실패 시 원본 텍스트 반환
                }
            });
        } catch (Exception e) {
            log.error("Unexpected error during translation cache access for text: '{}'", text, e);
            return text; // 캐시 접근 중 오류 발생 시 원본 텍스트 반환
        }
    }

    private String decodeHtmlEntities(String text) {
        return StringEscapeUtils.unescapeHtml4(text);
    }

    public DetectLanguageResponseDto detectLanguage(String text) {
        try {
            List<Detection> detections = translate.detect(ImmutableList.of(text));
            if (!detections.isEmpty()) {
                return DetectLanguageResponseDto.from(detections.get(0));
            }
        } catch (Exception e) {
            throw new CustomException(LANGUAGE_DETECTION_FAILED);
        }
        return DetectLanguageResponseDto.builder()
            .languageCode("und")
            .confidence(0.0f)
            .build();
    }
}