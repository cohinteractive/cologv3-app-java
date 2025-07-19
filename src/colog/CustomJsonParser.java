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

    private static class ParsedMessage {
        String id;
        String parentId;
        String role;
        String content;
        long createTime;
        List<String> children = new ArrayList<>();
    }

    private static List<String> inferTags(String prompt, String response) {
        List<String> tags = new ArrayList<>();
        String text = (prompt + " " + response).toLowerCase();

        if (text.contains("bug") || text.contains("fix")) tags.add("bug");
        if (text.contains("ui") || text.contains("layout")) tags.add("ui");
        if (text.contains("api") || text.contains("request")) tags.add("api");
        if (text.contains("performance")) tags.add("performance");
        if (text.contains("refactor")) tags.add("refactor");
        if (text.contains("firebase")) tags.add("firebase");

        return tags;
    }

    public static Conversation extractConversation(String rawJson) {
        String title = extractTitle(rawJson);
        Conversation conv = new Conversation(title == null ? "Untitled" : title);

        String mappingJson = extractMappingBlock(rawJson);
        Map<String, ParsedMessage> messages = parseMessages(mappingJson);

        for (ParsedMessage msg : messages.values()) {
            if (!"user".equals(msg.role)) continue;
            if (msg.children.isEmpty()) continue;
            ParsedMessage child = messages.get(msg.children.get(0));
            if (child == null) continue;
            if (!"assistant".equals(child.role)) continue;

            String prompt = msg.content;
            if (prompt == null || prompt.isBlank()) continue;
            String response = child.content == null ? "" : child.content;

            String ts = msg.createTime > 0
                    ? TIME_FMT.format(Instant.ofEpochSecond(msg.createTime))
                    : "";
            Exchange ex = new Exchange(ts, prompt, response);
            ex.tags = inferTags(prompt, response);
            conv.exchanges.add(ex);
        }

        System.out.println("[DEBUG] Extracted " + conv.exchanges.size() +
                " exchanges from conversation '" + title + "'");

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
        boolean inString = false;
        boolean escape = false;
        int depth = 0;
        int start = -1;
        for (int i = 0; i < mappingJson.length(); i++) {
            char c = mappingJson.charAt(i);
            if (escape) {
                escape = false;
                continue;
            }
            if (c == '\\') {
                escape = true;
                continue;
            }
            if (c == '"') {
                inString = !inString;
                continue;
            }
            if (!inString) {
                if (c == '{') {
                    depth++;
                    if (depth == 2) {
                        start = i;
                    }
                } else if (c == '}') {
                    if (depth == 2 && start >= 0) {
                        blocks.add(mappingJson.substring(start, i + 1));
                        start = -1;
                    }
                    depth--;
                }
            }
        }
        return blocks;
    }

    private static Map<String, ParsedMessage> parseMessages(String mappingBlock) {
        List<String> blocks = extractMessageBlocks(mappingBlock);
        Map<String, ParsedMessage> messages = new LinkedHashMap<>();
        for (String b : blocks) {
            String id = extractStringField(b, "id");
            if (id == null) continue;

            ParsedMessage pm = new ParsedMessage();
            pm.id = id;
            pm.parentId = extractStringField(b, "parent");
            pm.role = extractStringField(b, "role");
            pm.content = extractPart0(b);
            pm.createTime = extractLongField(b, "create_time");
            pm.children.addAll(extractArray(b, "children"));

            messages.put(pm.id, pm);
        }
        return messages;
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

    private static List<String> extractArray(String json, String field) {
        List<String> result = new ArrayList<>();
        int idx = json.indexOf("\"" + field + "\"");
        if (idx < 0) return result;
        int br = json.indexOf('[', idx);
        if (br < 0) return result;
        int end = br;
        int depth = 0;
        for (; end < json.length(); end++) {
            char c = json.charAt(end);
            if (c == '[') depth++;
            if (c == ']') { depth--; if (depth == 0) break; }
        }
        if (end <= br) return result;
        String arr = json.substring(br + 1, end);
        int pos = 0;
        while (true) {
            int q1 = arr.indexOf('"', pos);
            if (q1 < 0) break;
            int q2 = arr.indexOf('"', q1 + 1);
            if (q2 < 0) break;
            result.add(arr.substring(q1 + 1, q2));
            pos = q2 + 1;
        }
        return result;
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
