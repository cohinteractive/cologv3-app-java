package colog;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import static colog.Theme.*;

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
        setBackground(DARK_BG);
        setBorder(new LineBorder(LIGHT_TEXT));

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
        timeLabel.setForeground(LIGHT_TEXT);
        expandLabel.setForeground(LIGHT_TEXT);
        header.add(timeLabel);

        header.add(Box.createHorizontalGlue());
        header.setAlignmentX(LEFT_ALIGNMENT);
        add(header);

        summaryArea = createArea(firstLine(promptText));
        summaryArea.setRows(1);
        summaryArea.setMaximumSize(new Dimension(Integer.MAX_VALUE, summaryArea.getPreferredSize().height));
        summaryArea.setAlignmentX(LEFT_ALIGNMENT);
        summaryArea.setBackground(DARK_BG);
        summaryArea.setForeground(LIGHT_TEXT);
        add(summaryArea);

        add(Box.createVerticalStrut(4));

        promptArea = createArea(promptText);
        responseArea = createArea(responseText);

        promptSection = buildSection("Prompt", promptText, promptArea, PROMPT_BG, LIGHT_TEXT, false);
        responseSection = buildSection("Response", responseText, responseArea, RESPONSE_BG, LIGHT_TEXT, true);

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
            tagLabel.setForeground(LIGHT_TEXT);
            tagLabel.setBackground(TAG_BG);
            tagLabel.setOpaque(true);
            tagLabel.setBorder(new EmptyBorder(0, 4, 0, 4));
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
        area.setOpaque(true);
        area.setBackground(DARK_BG);
        area.setForeground(LIGHT_TEXT);
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
        panel.setBorder(new EmptyBorder(4, 4, 4, 4));

        JPanel wrapper = new JPanel();
        wrapper.setLayout(new BoxLayout(wrapper, BoxLayout.Y_AXIS));
        wrapper.setBorder(BorderFactory.createEmptyBorder(0, indent ? 20 : 0, 0, 0));
        wrapper.setOpaque(false);

        JLabel label = new JLabel(labelText);
        label.setFont(label.getFont().deriveFont(Font.BOLD));
        label.setForeground(fg);
        label.setBackground(bg);
        label.setOpaque(true);
        wrapper.add(label);

        JLabel summaryLabel = new JLabel("Summary: " + summarize(text));
        summaryLabel.setFont(summaryLabel.getFont().deriveFont(Font.ITALIC, 11f));
        summaryLabel.setForeground(fg);
        summaryLabel.setBackground(bg);
        summaryLabel.setOpaque(true);
        summaryLabel.setMaximumSize(new Dimension(Integer.MAX_VALUE, summaryLabel.getPreferredSize().height));
        wrapper.add(summaryLabel);

        wrapper.add(new JSeparator(SwingConstants.HORIZONTAL));

        area.setForeground(fg);
        area.setBackground(bg);
        wrapper.add(area);

        panel.add(wrapper);

        return panel;
    }

    private static String summarize(String text) {
        if (text == null) return "";
        String summary = text.replaceAll("\\s+", " ").strip();
        if (summary.length() > 80) summary = summary.substring(0, 80) + "…";
        return summary;
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
