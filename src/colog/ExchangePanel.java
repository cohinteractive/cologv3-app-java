package colog;

import javax.swing.*;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

/**
 * A single exchange row with timestamp, summary, tags, and expandable prompt/response text.
 */
public class ExchangePanel extends JPanel {
    private static final int DEFAULT_WIDTH = 600;

    private final String promptText;
    private final String responseText;

    private final JTextArea promptArea;
    private final JTextArea responseArea;
    private final JLabel expandLabel;
    private final int lineHeight;
    private boolean expanded = false;

    public ExchangePanel(String timestamp, String prompt, String response, String tags) {
        this.promptText = prompt == null ? "" : prompt;
        this.responseText = response == null ? "" : response;

        setLayout(new BorderLayout());
        setBorder(new LineBorder(Color.LIGHT_GRAY));

        // Create one area up-front to obtain font metrics for row height
        JTextArea metricsArea = new JTextArea();
        lineHeight = metricsArea.getFontMetrics(metricsArea.getFont()).getHeight();

        JLabel timeLabel = new JLabel(timestamp);
        timeLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        add(timeLabel, BorderLayout.WEST);

        JPanel textPanel = new JPanel();
        textPanel.setLayout(new BoxLayout(textPanel, BoxLayout.Y_AXIS));
        textPanel.setOpaque(false);

        promptArea = createArea("");
        textPanel.add(promptArea);
        responseArea = createArea(responseText);
        textPanel.add(responseArea);

        add(textPanel, BorderLayout.CENTER);

        JPanel rightPanel = new JPanel();
        rightPanel.setOpaque(false);
        rightPanel.setLayout(new BoxLayout(rightPanel, BoxLayout.X_AXIS));

        JLabel tagsLabel = new JLabel(tags);
        tagsLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        rightPanel.add(tagsLabel);

        expandLabel = new JLabel("\u2BC8");
        expandLabel.setBorder(BorderFactory.createEmptyBorder(0, 10, 0, 5));
        expandLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        expandLabel.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                toggleExpanded();
            }
        });
        rightPanel.add(expandLabel);

        add(rightPanel, BorderLayout.EAST);

        collapse();
    }

    private JTextArea createArea(String text) {
        JTextArea area = new JTextArea(text);
        area.setLineWrap(true);
        area.setWrapStyleWord(true);
        area.setEditable(false);
        area.setOpaque(false);
        area.setAlignmentX(LEFT_ALIGNMENT);
        return area;
    }

    private String firstLine(String text) {
        if (text == null) return "";
        int idx = text.indexOf('\n');
        return idx >= 0 ? text.substring(0, idx) : text;
    }

    private int countLines(String text) {
        if (text == null || text.isEmpty()) return 1;
        int lines = 1;
        for (int i = 0; i < text.length(); i++) {
            if (text.charAt(i) == '\n') lines++;
        }
        return lines;
    }

    private void collapse() {
        expanded = false;
        promptArea.setText(firstLine(promptText));
        responseArea.setVisible(false);
        setPreferredSize(new Dimension(DEFAULT_WIDTH, lineHeight));
        setMaximumSize(new Dimension(Integer.MAX_VALUE, lineHeight));
        revalidate();
    }

    private void expand() {
        expanded = true;
        promptArea.setText(promptText);
        responseArea.setText(responseText);
        responseArea.setVisible(true);
        int lines = countLines(promptText) + countLines(responseText);
        int height = lineHeight * lines;
        setPreferredSize(new Dimension(DEFAULT_WIDTH, height));
        setMaximumSize(new Dimension(Integer.MAX_VALUE, height));
        revalidate();
    }

    private void toggleExpanded() {
        if (expanded) {
            collapse();
        } else {
            expand();
        }
    }
}
