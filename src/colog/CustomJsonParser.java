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

        String mapping = extractMappingBlock(rawJson);
        Map<String, String> messageBlocks = extractMessageBlocks(mapping);
        List<Exchange> exchanges = extractPromptResponsePairs(messageBlocks);
        conv.exchanges.addAll(exchanges);

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
        int mapIndex = json.indexOf("\"mapping\"");
        if (mapIndex < 0) return "";
        int start = json.indexOf("{", mapIndex);
        if (start < 0) return "";
        int depth = 0;
        for (int i = start; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '{') depth++;
            else if (c == '}') {
                depth--;
                if (depth == 0) {
                    return json.substring(start, i + 1);
                }
            }
        }
        return "";
    }

    private static Map<String, String> extractMessageBlocks(String mappingJson) {
        Map<String, String> result = new LinkedHashMap<>();
        if (mappingJson == null || mappingJson.isBlank()) return result;
        int pos = mappingJson.indexOf('{') + 1;
        while (pos > 0 && pos < mappingJson.length()) {
            int q1 = mappingJson.indexOf('"', pos);
            if (q1 < 0) break;
            int q2 = mappingJson.indexOf('"', q1 + 1);
            if (q2 < 0) break;
            String id = mappingJson.substring(q1 + 1, q2);
            int colon = mappingJson.indexOf(':', q2);
            int brace = mappingJson.indexOf('{', colon);
            if (brace < 0) break;
            int depth = 0;
            int i = brace;
            for (; i < mappingJson.length(); i++) {
                char c = mappingJson.charAt(i);
                if (c == '{') depth++;
                else if (c == '}') {
                    depth--;
                    if (depth == 0) {
                        i++; // include closing brace
                        break;
                    }
                }
            }
            String block = mappingJson.substring(brace, i);
            pos = i;
            boolean hasRole = block.contains("\"role\":\"user\"") ||
                    block.contains("\"role\": \"user\"") ||
                    block.contains("\"role\":\"assistant\"") ||
                    block.contains("\"role\": \"assistant\"");
            if (block.contains("\"author\"") && block.contains("\"content\"") && hasRole) {
                result.put(id, block);
            }
            if (pos < mappingJson.length() && mappingJson.charAt(pos) == ',') pos++;
        }
        return result;
    }

    private static class Node {
        String id;
        String parent;
        String firstChild;
        String role;
        String text;
        long time;
    }

    private static List<Exchange> extractPromptResponsePairs(Map<String, String> blocks) {
        Map<String, Node> nodes = new LinkedHashMap<>();
        for (Map.Entry<String, String> e : blocks.entrySet()) {
            String id = e.getKey();
            String block = e.getValue();
            Node n = new Node();
            n.id = id;
            n.parent = extractStringField(block, "parent");
            n.firstChild = extractArrayFirst(block, "children");
            n.role = extractStringField(block, "role");
            n.text = extractPart0(block);
            n.time = extractLongField(block, "create_time");
            nodes.put(id, n);
        }

        List<Exchange> exchanges = new ArrayList<>();
        for (Node n : nodes.values()) {
            if ("user".equals(n.role)) {
                Node child = nodes.get(n.firstChild);
                if (child != null && "assistant".equals(child.role)) {
                    String ts = TIME_FMT.format(Instant.ofEpochSecond(n.time));
                    exchanges.add(new Exchange(ts, n.text, child.text));
                }
            }
        }
        return exchanges;
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
