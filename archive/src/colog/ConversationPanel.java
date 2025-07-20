package colog;

import javax.swing.*;
import java.awt.*;
import static colog.UIStyle.*;
import static colog.Theme.*;

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
        setBackground(DARK_BG);
        setOpaque(true);

        JPanel titlePanel = new JPanel();
        titlePanel.setLayout(new BoxLayout(titlePanel, BoxLayout.X_AXIS));
        titlePanel.setBackground(new Color(32, 32, 32));
        titlePanel.setOpaque(true);
        titlePanel.setBorder(BorderFactory.createEmptyBorder(4, 12, 4, 12));

        JLabel titleLabel = new JLabel(title);
        titleLabel.setFont(BASE_FONT.deriveFont(Font.BOLD, BASE_FONT.getSize2D() + 2f));
        titleLabel.setForeground(new Color(220, 220, 220));
        titlePanel.add(titleLabel);

        FontMetrics fm = getFontMetrics(titleLabel.getFont());
        int height = fm.getHeight() + 8; // 4px top/bottom padding
        Dimension d = new Dimension(Short.MAX_VALUE, height);
        titlePanel.setPreferredSize(d);
        titlePanel.setMaximumSize(d);
        titlePanel.setAlignmentX(LEFT_ALIGNMENT);
        add(titlePanel);

        JSeparator separator = new JSeparator(SwingConstants.HORIZONTAL);
        separator.setForeground(new Color(80, 80, 80));
        separator.setMaximumSize(new Dimension(Integer.MAX_VALUE, 1));
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
