package colog;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class JsonParser {
    private static final DateTimeFormatter TIME_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").withZone(ZoneId.systemDefault());

    public static Conversation parseConversationFromFile(File file) throws IOException {
        String content = Files.readString(file.toPath());
        JSONObject root = new JSONObject(content);
        String title = root.optString("title", file.getName());
        Conversation conversation = new Conversation(title);

        JSONObject mapping = root.getJSONObject("mapping");
        String nodeId = "client-created-root";
        JSONObject node = mapping.optJSONObject(nodeId);
        if (node == null) return conversation;

        List<String> queue = toList(node.optJSONArray("children"));
        while (!queue.isEmpty()) {
            nodeId = queue.remove(0);
            node = mapping.optJSONObject(nodeId);
            if (node == null) continue;
            JSONObject message = node.optJSONObject("message");
            if (message == null) {
                queue.addAll(toList(node.optJSONArray("children")));
                continue;
            }
            String role = message.optJSONObject("author").optString("role", "");
            if ("user".equals(role)) {
                String prompt = firstPart(message);
                long ts = (long) message.optDouble("create_time", 0);
                String timestamp = ts > 0 ? TIME_FMT.format(Instant.ofEpochSecond(ts)) : "";
                String response = "";
                JSONArray children = node.optJSONArray("children");
                String nextId = null;
                if (children != null) {
                    for (int i = 0; i < children.length(); i++) {
                        String cid = children.getString(i);
                        JSONObject cnode = mapping.optJSONObject(cid);
                        if (cnode != null) {
                            JSONObject cm = cnode.optJSONObject("message");
                            if (cm != null && "assistant".equals(cm.optJSONObject("author").optString("role"))) {
                                response = firstPart(cm);
                                nextId = cid;
                                break;
                            }
                        }
                    }
                }
                conversation.exchanges.add(new Exchange(timestamp, prompt, response));
                if (nextId != null) {
                    queue.clear();
                    queue.addAll(toList(mapping.getJSONObject(nextId).optJSONArray("children")));
                }
            } else {
                queue.addAll(toList(node.optJSONArray("children")));
            }
        }
        return conversation;
    }

    private static List<String> toList(JSONArray arr) {
        List<String> list = new ArrayList<>();
        if (arr != null) {
            for (int i = 0; i < arr.length(); i++) {
                list.add(arr.getString(i));
            }
        }
        return list;
    }

    private static String firstPart(JSONObject message) {
        if (message == null) return "";
        JSONObject content = message.optJSONObject("content");
        if (content != null) {
            JSONArray parts = content.optJSONArray("parts");
            if (parts != null && parts.length() > 0) {
                return parts.getString(0);
            }
        }
        return "";
    }
}
