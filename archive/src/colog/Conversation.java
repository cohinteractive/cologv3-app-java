package colog;

import java.util.ArrayList;
import java.util.List;

public class Conversation {
    public String title;
    public List<Exchange> exchanges = new ArrayList<>();

    public Conversation(String title) {
        this.title = title;
    }
}
