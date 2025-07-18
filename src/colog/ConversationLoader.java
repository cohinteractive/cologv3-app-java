package colog;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

public class ConversationLoader {
    public static Conversation parseConversationFromFile(File file) throws IOException {
        String json = Files.readString(file.toPath(), StandardCharsets.UTF_8);
        return CustomJsonParser.extractConversation(json);
    }
}
