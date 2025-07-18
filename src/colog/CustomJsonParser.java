package colog;

public class CustomJsonParser {
    public static Conversation extractConversation(String rawJson) {
        // Stub: parse title, then mapping block manually
        // Later: build Exchange objects by walking prompt/response pairs
        Conversation conv = new Conversation("Unknown");

        // TODO: implement parsing of "title"
        // TODO: implement scanning of "mapping" block
        // TODO: extract prompt/response pairs and timestamps

        // Hardcoded stub data
        conv.exchanges.add(new Exchange("2024-01-01 00:00:00", "Example prompt", "Example response"));
        conv.exchanges.add(new Exchange("2024-01-01 00:01:00", "Second prompt", "Second response"));

        return conv;
    }
}
