package colog;

import java.io.File;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.List;

public class ConversationLoader {
    public static List<Conversation> parseConversationsFromFile(File file) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            return CustomJsonParser.parseFromReader(reader);
        }
    }
}
