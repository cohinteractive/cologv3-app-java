package colog;

import javax.swing.*;
import java.awt.*;

/**
 * Displays a conversation title followed by its exchange panels.
 */
public class ConversationPanel extends JPanel {
    public ConversationPanel(Conversation conversation) {
        this(conversation.title, conversation.exchanges);
    }

    public ConversationPanel(String title, java.util.List<Exchange> visibleExchanges) {
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));

        JLabel titleLabel = new JLabel(title);
        titleLabel.setFont(titleLabel.getFont().deriveFont(Font.BOLD, 16f));
        add(titleLabel);

        JSeparator separator = new JSeparator(SwingConstants.HORIZONTAL);
        add(separator);

        for (Exchange ex : visibleExchanges) {
            add(new ExchangePanel(ex));
        }

        setBorder(BorderFactory.createEmptyBorder(10, 0, 20, 0));
    }
}
