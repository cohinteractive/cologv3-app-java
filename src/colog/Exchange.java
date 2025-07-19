package colog;

import java.util.ArrayList;
import java.util.List;

public class Exchange {
    public String timestamp;
    public String prompt;
    public String response;
    public List<String> tags = new ArrayList<>();
    public String summary;
    public boolean isExpanded = false;

    public Exchange(String timestamp, String prompt, String response) {
        this.timestamp = timestamp;
        this.prompt = prompt;
        this.response = response;
        this.summary = generateSummary(prompt, response);
    }

    private static String generateSummary(String prompt, String response) {
        if (prompt != null && !prompt.isBlank()) {
            String cleaned = prompt.strip().replaceAll("[\\r\\n]+", " ");
            return cleaned.length() > 200 ? cleaned.substring(0, 200) + "…" : cleaned;
        }
        if (response != null && !response.isBlank()) {
            String cleaned = response.strip().replaceAll("[\\r\\n]+", " ");
            return cleaned.length() > 200 ? cleaned.substring(0, 200) + "…" : cleaned;
        }
        return "(no content)";
    }
}
