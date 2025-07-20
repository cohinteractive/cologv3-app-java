package colog;

import javax.swing.*;
import java.awt.*;
import static colog.UIStyle.*;

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
        titleLabel.setFont(BASE_FONT.deriveFont(Font.BOLD, 18f));
        add(titleLabel);

        JSeparator separator = new JSeparator(SwingConstants.HORIZONTAL);
        add(separator);

        if (visibleExchanges.isEmpty()) {
            JLabel empty = new JLabel("(No exchanges)");
            empty.setFont(BASE_FONT);
            add(empty);
        }
        for (Exchange ex : visibleExchanges) {
            ExchangePanel ep = new ExchangePanel(ex);
            panels.add(ep);
            add(ep);
        }

        // Remove excess top/bottom padding so exchanges align tightly
        setBorder(BorderFactory.createEmptyBorder(0, 0, 0, 0));
    }

    public java.util.List<ExchangePanel> getExchangePanels() {
        return panels;
    }
}
