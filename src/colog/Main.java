package colog;

import javax.swing.*;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileNameExtensionFilter;

import java.awt.*;
import java.io.*;
import java.util.ArrayList;
import java.util.List;


public class Main {
    private static File lastDir;
    private static JPanel container;
    private static JScrollPane scrollPane;
    private static JFrame frame;
    private static JTextField searchField;
    private static List<Conversation> allConversations = new ArrayList<>();
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> createAndShowGUI());
    }

    private static void createAndShowGUI() {
        frame = new JFrame("Colog V3");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(800, 600);
        frame.setResizable(true);

        JMenuBar menuBar = new JMenuBar();
        JMenu fileMenu = new JMenu("File");

        JMenuItem openItem = new JMenuItem("Open");
        openItem.addActionListener(e -> handleOpen(frame));
        fileMenu.add(openItem);

        JMenuItem exitItem = new JMenuItem("Exit");
        exitItem.addActionListener(e -> System.exit(0));
        fileMenu.add(exitItem);

        menuBar.add(fileMenu);
        frame.setJMenuBar(menuBar);

        container = new JPanel();
        container.setLayout(new BoxLayout(container, BoxLayout.Y_AXIS));

        scrollPane = new JScrollPane(container);

        JPanel searchPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        searchPanel.add(new JLabel("Search: "));
        searchField = new JTextField(40);
        searchPanel.add(searchField);
        searchField.getDocument().addDocumentListener(new DocumentListener() {
            @Override
            public void insertUpdate(DocumentEvent e) { applyFilter(); }

            @Override
            public void removeUpdate(DocumentEvent e) { applyFilter(); }

            @Override
            public void changedUpdate(DocumentEvent e) { applyFilter(); }
        });

        JPanel rootPanel = new JPanel(new BorderLayout());
        rootPanel.add(searchPanel, BorderLayout.NORTH);
        rootPanel.add(scrollPane, BorderLayout.CENTER);

        frame.setContentPane(rootPanel);

        frame.setVisible(true);
    }

    private static void handleOpen(JFrame parent) {
        JFileChooser chooser = new JFileChooser(lastDir);
        FileNameExtensionFilter filter = new FileNameExtensionFilter("JSON files", "json");
        chooser.setFileFilter(filter);
        int result = chooser.showOpenDialog(parent);
        if (result == JFileChooser.APPROVE_OPTION) {
            File selected = chooser.getSelectedFile();
            lastDir = selected.getParentFile();
            if (!selected.getName().toLowerCase().endsWith(".json")) {
                JOptionPane.showMessageDialog(parent, "Please select a .json file.",
                        "Invalid File", JOptionPane.ERROR_MESSAGE);
                return;
            }
            try {
                allConversations = ConversationLoader.parseConversationsFromFile(selected);
                applyFilter();
            } catch (IOException ex) {
                JOptionPane.showMessageDialog(parent, "Error reading file: " + ex.getMessage(),
                        "Read Error", JOptionPane.ERROR_MESSAGE);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(parent, "Failed to parse JSON: " + ex.getMessage(),
                        "Parse Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    private static void applyFilter() {
        if (scrollPane == null) return;
        String query = searchField.getText().toLowerCase();

        JScrollBar bar = scrollPane.getVerticalScrollBar();
        int val = bar.getValue();

        container.removeAll();
        for (Conversation c : allConversations) {
            List<Exchange> matches = new ArrayList<>();
            for (Exchange ex : c.exchanges) {
                String tags = String.join(" ", ex.tags).toLowerCase();
                if (query.isBlank() ||
                        (ex.prompt != null && ex.prompt.toLowerCase().contains(query)) ||
                        (ex.response != null && ex.response.toLowerCase().contains(query)) ||
                        (ex.summary != null && ex.summary.toLowerCase().contains(query)) ||
                        tags.contains(query)) {
                    matches.add(ex);
                }
            }
            if (!matches.isEmpty()) {
                container.add(new ConversationPanel(c.title, matches));
            }
        }
        container.revalidate();
        container.repaint();
        scrollPane.revalidate();
        bar.setValue(val);
    }
}
