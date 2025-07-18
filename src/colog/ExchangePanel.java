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

    private final JTextArea summaryArea;
    private final JTextArea promptArea;
    private final JTextArea responseArea;
    private final JLabel expandLabel;
    private final int lineHeight;
    private boolean isExpanded = false;

    public ExchangePanel(String timestamp, String prompt, String response, String tags) {
        this.promptText = prompt == null ? "" : prompt;
        this.responseText = response == null ? "" : response;

        setLayout(new BorderLayout());
        setBorder(new LineBorder(Color.LIGHT_GRAY));

        // Create one area up-front to obtain font metrics for row height
        JTextArea metricsArea = new JTextArea();
        lineHeight = metricsArea.getFontMetrics(metricsArea.getFont()).getHeight();

        JPanel leftPanel = new JPanel();
        leftPanel.setOpaque(false);
        leftPanel.setLayout(new BoxLayout(leftPanel, BoxLayout.X_AXIS));

        expandLabel = new JLabel("\u2BC8");
        expandLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        expandLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        expandLabel.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                toggleExpanded();
            }
        });
        leftPanel.add(expandLabel);

        JLabel timeLabel = new JLabel(timestamp);
        timeLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        leftPanel.add(timeLabel);
        add(leftPanel, BorderLayout.WEST);

        JPanel textPanel = new JPanel();
        textPanel.setLayout(new BoxLayout(textPanel, BoxLayout.Y_AXIS));
        textPanel.setOpaque(false);

        summaryArea = createArea(firstLine(promptText));
        textPanel.add(summaryArea);

        promptArea = createArea(promptText);
        promptArea.setVisible(false);
        textPanel.add(promptArea);

        responseArea = createArea(responseText);
        responseArea.setVisible(false);
        textPanel.add(responseArea);

        add(textPanel, BorderLayout.CENTER);

        JPanel rightPanel = new JPanel();
        rightPanel.setOpaque(false);
        rightPanel.setLayout(new BoxLayout(rightPanel, BoxLayout.X_AXIS));

        JLabel tagsLabel = new JLabel(tags);
        tagsLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        rightPanel.add(tagsLabel);

        rightPanel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));

        add(rightPanel, BorderLayout.EAST);

        updateLayout();
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

    private void updateLayout() {
        summaryArea.setVisible(!isExpanded);
        promptArea.setVisible(isExpanded);
        responseArea.setVisible(isExpanded);
        expandLabel.setText(isExpanded ? "\u2BC6" : "\u2BC8");

        int lines = isExpanded ? countLines(promptText) + countLines(responseText) : 1;
        int height = lineHeight * lines;
        setPreferredSize(new Dimension(DEFAULT_WIDTH, height));
        setMaximumSize(new Dimension(Integer.MAX_VALUE, height));
        revalidate();
        repaint();
    }

    private void toggleExpanded() {
        isExpanded = !isExpanded;
        updateLayout();
    }
}
