package colog;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CustomJsonParser {

    private static final DateTimeFormatter TIME_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
                    .withZone(ZoneId.systemDefault());

    public static Conversation extractConversation(String rawJson) {
        String title = extractTitle(rawJson);
        Conversation conv = new Conversation(title == null ? "Untitled" : title);

        String mappingJson = extractMappingBlock(rawJson);
        List<String> blocks = extractMessageBlocks(mappingJson);

        Map<String, String> blockById = new LinkedHashMap<>();
        for (String b : blocks) {
            String id = extractStringField(b, "id");
            if (id != null) {
                blockById.put(id, b);
            }
        }

        for (String b : blocks) {
            String role = extractStringField(b, "role");
            if (!"user".equals(role)) continue;
            String prompt = extractPart0(b);
            if (prompt == null || prompt.isEmpty()) continue;

            String childId = extractArrayFirst(b, "children");
            if (childId == null) continue;
            String childBlock = blockById.get(childId);
            if (childBlock == null) continue;
            String childRole = extractStringField(childBlock, "role");
            if (!"assistant".equals(childRole)) continue;
            String response = extractPart0(childBlock);
            long time = extractLongField(b, "create_time");
            String ts = TIME_FMT.format(Instant.ofEpochSecond(time));
            conv.exchanges.add(new Exchange(ts, prompt, response));
        }

        return conv;
    }

    private static String extractTitle(String rawJson) {
        int titleIndex = rawJson.indexOf("\"title\"");
        if (titleIndex < 0) return null;
        int colon = rawJson.indexOf(":", titleIndex);
        int firstQuote = rawJson.indexOf("\"", colon + 1);
        int secondQuote = rawJson.indexOf("\"", firstQuote + 1);
        if (firstQuote < 0 || secondQuote < 0) return null;
        return rawJson.substring(firstQuote + 1, secondQuote);
    }

    private static String extractMappingBlock(String json) {
        int start = json.indexOf("\"mapping\"");
        int braceStart = json.indexOf('{', start);
        int depth = 0;
        int end = braceStart;

        for (; end < json.length(); end++) {
            char c = json.charAt(end);
            if (c == '{') depth++;
            if (c == '}') depth--;
            if (depth == 0) break;
        }
        return json.substring(braceStart, end + 1);
    }

    private static List<String> extractMessageBlocks(String mappingJson) {
        List<String> blocks = new ArrayList<>();
        int pos = 0;
        while ((pos = mappingJson.indexOf("{", pos)) != -1) {
            int depth = 0, start = pos, end = pos;
            for (; end < mappingJson.length(); end++) {
                char c = mappingJson.charAt(end);
                if (c == '{') depth++;
                if (c == '}') depth--;
                if (depth == 0) break;
            }
            blocks.add(mappingJson.substring(start, end + 1));
            pos = end + 1;
        }
        return blocks;
    }


    private static String extractStringField(String json, String field) {
        int idx = json.indexOf("\"" + field + "\"");
        if (idx < 0) return null;
        int colon = json.indexOf(':', idx);
        int firstQuote = json.indexOf('"', colon + 1);
        if (firstQuote < 0) {
            int start = colon + 1;
            while (start < json.length() && Character.isWhitespace(json.charAt(start))) start++;
            if (json.startsWith("null", start)) return null;
            return null;
        }
        int secondQuote = json.indexOf('"', firstQuote + 1);
        if (secondQuote < 0) return null;
        return json.substring(firstQuote + 1, secondQuote);
    }

    private static long extractLongField(String json, String field) {
        int idx = json.indexOf("\"" + field + "\"");
        if (idx < 0) return 0L;
        int colon = json.indexOf(':', idx);
        int start = colon + 1;
        while (start < json.length() && !Character.isDigit(json.charAt(start))) start++;
        int end = start;
        while (end < json.length() && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '.')) end++;
        if (start >= end) return 0L;
        try {
            double val = Double.parseDouble(json.substring(start, end));
            return (long) val;
        } catch (NumberFormatException ex) {
            return 0L;
        }
    }

    private static String extractArrayFirst(String json, String field) {
        int idx = json.indexOf("\"" + field + "\"");
        if (idx < 0) return null;
        int br = json.indexOf('[', idx);
        if (br < 0) return null;
        int q1 = json.indexOf('"', br);
        if (q1 < 0) return null;
        int q2 = json.indexOf('"', q1 + 1);
        if (q2 < 0) return null;
        return json.substring(q1 + 1, q2);
    }

    private static String extractPart0(String json) {
        int contentIdx = json.indexOf("\"content\"");
        if (contentIdx < 0) return "";
        int partsIdx = json.indexOf("\"parts\"", contentIdx);
        if (partsIdx < 0) return "";
        int br = json.indexOf('[', partsIdx);
        if (br < 0) return "";
        int q1 = json.indexOf('"', br);
        if (q1 < 0) return "";
        int q2 = json.indexOf('"', q1 + 1);
        if (q2 < 0) return "";
        return json.substring(q1 + 1, q2);
    }
}
