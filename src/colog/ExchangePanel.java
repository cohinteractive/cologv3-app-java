package colog;

import javax.swing.*;
import javax.swing.border.LineBorder;
import java.awt.*;

/**
 * A single exchange row with timestamp, summary, tags, and expand icon.
 */
public class ExchangePanel extends JPanel {
    private static final int ROW_HEIGHT = 50;

    public ExchangePanel(String timestamp, String summary, String tags) {
        setLayout(new BorderLayout());
        setBorder(new LineBorder(Color.LIGHT_GRAY));
        setMaximumSize(new Dimension(Integer.MAX_VALUE, ROW_HEIGHT));
        setPreferredSize(new Dimension(600, ROW_HEIGHT));

        JLabel timeLabel = new JLabel(timestamp);
        timeLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        add(timeLabel, BorderLayout.WEST);

        JLabel summaryLabel = new JLabel("<html>" + summary + "</html>");
        summaryLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        add(summaryLabel, BorderLayout.CENTER);

        JPanel rightPanel = new JPanel();
        rightPanel.setOpaque(false);
        rightPanel.setLayout(new BoxLayout(rightPanel, BoxLayout.X_AXIS));

        JLabel tagsLabel = new JLabel(tags);
        tagsLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        rightPanel.add(tagsLabel);

        JLabel expandLabel = new JLabel("\u2BC8"); // placeholder icon
        expandLabel.setBorder(BorderFactory.createEmptyBorder(0, 10, 0, 5));
        rightPanel.add(expandLabel);

        add(rightPanel, BorderLayout.EAST);
    }
}
