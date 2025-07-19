package colog;

import javax.swing.*;
import java.awt.*;

/**
 * Displays a conversation title followed by its exchange panels.
 */
public class ConversationPanel extends JPanel {
    private java.util.List<ExchangePanel> panels = new java.util.ArrayList<>();

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

        if (visibleExchanges.isEmpty()) {
            add(new JLabel("(No exchanges)"));
        }
        for (Exchange ex : visibleExchanges) {
            ExchangePanel ep = new ExchangePanel(ex);
            panels.add(ep);
            add(ep);
        }

        setBorder(BorderFactory.createEmptyBorder(10, 0, 20, 0));
    }

    public java.util.List<ExchangePanel> getExchangePanels() {
        return panels;
    }
}
