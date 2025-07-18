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

    private String generateSummary(String prompt, String response) {
        if (prompt == null || prompt.isBlank()) return "No summary";
        int end = prompt.indexOf('\n');
        return end > 0 ? prompt.substring(0, end).trim() : prompt.trim();
    }
}
