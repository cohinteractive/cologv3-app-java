package colog;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.util.List;

/**
 * Container for multiple ExchangePanels representing a conversation.
 */
public class ConversationPanel extends JPanel {
    public ConversationPanel(String title, List<ExchangePanel> exchanges) {
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setBorder(new LineBorder(Color.DARK_GRAY));
        setAlignmentX(LEFT_ALIGNMENT);

        JLabel titleLabel = new JLabel(title);
        titleLabel.setBorder(new EmptyBorder(5, 5, 5, 5));
        add(titleLabel);

        for (ExchangePanel ex : exchanges) {
            add(ex);
        }
    }
}
