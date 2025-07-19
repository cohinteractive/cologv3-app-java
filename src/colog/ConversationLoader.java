package colog;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;

public class ConversationLoader {
    public static List<Conversation> parseConversationsFromFile(File file) throws IOException {
        String rawJson = Files.readString(file.toPath(), StandardCharsets.UTF_8);
        if (rawJson.trim().startsWith("[")) {
            List<String> blocks = extractJsonObjectsFromArray(rawJson);
            List<Conversation> all = new ArrayList<>();
            for (String block : blocks) {
                all.add(CustomJsonParser.extractConversation(block));
            }
            return all;
        } else {
            return List.of(CustomJsonParser.extractConversation(rawJson));
        }
    }

    private static List<String> extractJsonObjectsFromArray(String json) {
        List<String> blocks = new ArrayList<>();
        boolean inString = false;
        boolean escape = false;
        int depth = 0;
        int start = -1;
        for (int i = 0; i < json.length(); i++) {
            char c = json.charAt(i);
            if (escape) {
                escape = false;
            } else if (c == '\\') {
                escape = true;
            } else if (c == '"') {
                inString = !inString;
            } else if (!inString) {
                if (c == '{') {
                    if (depth == 0) start = i;
                    depth++;
                } else if (c == '}') {
                    depth--;
                    if (depth == 0 && start >= 0) {
                        blocks.add(json.substring(start, i + 1));
                        start = -1;
                    }
                }
            }
        }
        return blocks;
    }
}
