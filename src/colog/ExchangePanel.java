package colog;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

/**
 * A single exchange row with timestamp, summary, tags, and expandable prompt/response text.
 */
public class ExchangePanel extends JPanel {

    private final String promptText;
    private final String responseText;

    private final JTextArea summaryArea;
    private final JTextArea promptArea;
    private final JTextArea responseArea;
    private final JPanel promptSection;
    private final JPanel responseSection;
    private final JLabel expandLabel;
    private boolean isExpanded = false;
    private Exchange exchange;

    public ExchangePanel(Exchange ex) {
        this(ex.timestamp, ex.prompt, ex.response, ex.tags);
        this.exchange = ex;
        this.isExpanded = ex.isExpanded;
        updateLayout();
    }

    private ExchangePanel(String timestamp, String prompt, String response, java.util.List<String> tagsList) {
        this.promptText = prompt == null ? "" : prompt.replace("\\n", "\n");
        this.responseText = response == null ? "" : response.replace("\\n", "\n");
        this.exchange = null;

        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setBorder(new LineBorder(Color.LIGHT_GRAY));

        JPanel header = new JPanel();
        header.setLayout(new BoxLayout(header, BoxLayout.X_AXIS));
        header.setOpaque(false);

        expandLabel = new JLabel("\u2BC8");
        expandLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        expandLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        expandLabel.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                toggleExpanded();
            }
        });
        header.add(expandLabel);

        JLabel timeLabel = new JLabel(timestamp);
        timeLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        header.add(timeLabel);

        header.add(Box.createHorizontalGlue());
        header.setAlignmentX(LEFT_ALIGNMENT);
        add(header);

        summaryArea = createArea(firstLine(promptText));
        summaryArea.setRows(1);
        summaryArea.setMaximumSize(new Dimension(Integer.MAX_VALUE, summaryArea.getPreferredSize().height));
        summaryArea.setAlignmentX(LEFT_ALIGNMENT);
        add(summaryArea);

        add(Box.createVerticalStrut(4));

        promptArea = createArea(promptText);
        responseArea = createArea(responseText);

        promptSection = buildSection("Prompt", promptText, promptArea, new Color(230, 230, 230), Color.BLACK, false);
        responseSection = buildSection("Response", responseText, responseArea, new Color(60, 60, 60), Color.WHITE, true);

        promptSection.setVisible(false);
        responseSection.setVisible(false);

        add(promptSection);
        add(Box.createVerticalStrut(8));
        add(responseSection);

        JPanel tagPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 0));
        tagPanel.setOpaque(false);
        for (String tag : tagsList) {
            final String t = tag;
            JLabel tagLabel = new JLabel("#" + tag);
            tagLabel.setForeground(new Color(30, 30, 200));
            tagLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            tagLabel.setToolTipText("Click to filter by #" + tag);
            tagLabel.addMouseListener(new MouseAdapter() {
                @Override
                public void mouseClicked(MouseEvent e) {
                    TagFilter.setActiveTag(t);
                }

                @Override
                public void mouseEntered(MouseEvent e) {
                    tagLabel.setFont(tagLabel.getFont().deriveFont(Font.BOLD));
                }

                @Override
                public void mouseExited(MouseEvent e) {
                    tagLabel.setFont(tagLabel.getFont().deriveFont(Font.PLAIN));
                }
            });
            tagPanel.add(tagLabel);
        }
        tagPanel.setAlignmentX(LEFT_ALIGNMENT);
        add(tagPanel);

        updateLayout();
    }

    private JTextArea createArea(String text) {
        if (text == null) text = "";
        text = text.replace("\\n", "\n");
        JTextArea area = new JTextArea(text);
        area.setLineWrap(true);
        area.setWrapStyleWord(true);
        area.setOpaque(false);
        area.setEditable(false);
        area.setFocusable(false);
        area.setBorder(null);
        area.setAlignmentX(LEFT_ALIGNMENT);
        return area;
    }

    private JPanel buildSection(String labelText, String text, JTextArea area,
                                Color bg, Color fg, boolean indent) {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBackground(bg);
        panel.setOpaque(true);
        panel.setAlignmentX(LEFT_ALIGNMENT);
        panel.setBorder(new EmptyBorder(4, indent ? 12 : 4, 4, 4));

        JLabel label = new JLabel(labelText);
        label.setFont(label.getFont().deriveFont(Font.BOLD));
        label.setForeground(fg);
        panel.add(label);

        JLabel summary = new JLabel("Summary: " + firstChars(text, 80));
        summary.setFont(summary.getFont().deriveFont(summary.getFont().getSize2D() - 2f));
        summary.setForeground(fg);
        panel.add(summary);

        panel.add(new JSeparator(SwingConstants.HORIZONTAL));

        area.setForeground(fg);
        panel.add(area);

        return panel;
    }

    private static String firstChars(String text, int len) {
        if (text == null) return "";
        text = text.replace("\n", " ").replace("\\n", " ");
        return text.length() > len ? text.substring(0, len) : text;
    }

    private String firstLine(String text) {
        if (text == null) return "";
        int idx = text.indexOf('\n');
        return idx >= 0 ? text.substring(0, idx) : text;
    }

    private void updateLayout() {
        summaryArea.setVisible(true);
        promptSection.setVisible(isExpanded);
        responseSection.setVisible(isExpanded);
        expandLabel.setText(isExpanded ? "\u2BC6" : "\u2BC8");

        revalidate();
        repaint();
    }

    private void toggleExpanded() {
        JScrollPane pane = (JScrollPane) SwingUtilities.getAncestorOfClass(JScrollPane.class, this);
        JScrollBar bar = pane == null ? null : pane.getVerticalScrollBar();
        int val = bar == null ? 0 : bar.getValue();

        isExpanded = !isExpanded;
        if (exchange != null) {
            exchange.isExpanded = isExpanded;
        }
        updateLayout();

        if (bar != null) {
            bar.setValue(val);
        }
    }

    /**
     * Expands this panel if collapsed and scrolls it into view.
     */
    public void expandAndFocus() {
        if (!isExpanded) {
            toggleExpanded();
        }
        scrollRectToVisible(getBounds());
    }
}
