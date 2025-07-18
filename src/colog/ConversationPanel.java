package colog;

import javax.swing.*;
import java.awt.*;

/**
 * Displays a conversation title followed by its exchange panels.
 */
public class ConversationPanel extends JPanel {
    public ConversationPanel(Conversation conversation) {
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));

        JLabel titleLabel = new JLabel(conversation.title);
        titleLabel.setFont(titleLabel.getFont().deriveFont(Font.BOLD, 16f));
        add(titleLabel);

        JSeparator separator = new JSeparator(SwingConstants.HORIZONTAL);
        add(separator);

        for (Exchange ex : conversation.exchanges) {
            add(new ExchangePanel(ex));
        }

        setBorder(BorderFactory.createEmptyBorder(10, 0, 20, 0));
    }
}
