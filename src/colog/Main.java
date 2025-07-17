package colog;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;

import java.awt.*;
import java.io.*;
import java.util.List;

public class Main {
    private static File lastDir;
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> createAndShowGUI());
    }

    private static void createAndShowGUI() {
        JFrame frame = new JFrame("Colog V3");
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

        JPanel container = new JPanel();
        container.setLayout(new BoxLayout(container, BoxLayout.Y_AXIS));

        ConversationPanel c1 = new ConversationPanel("Conversation A", List.of(
                new ExchangePanel("10:00", "Prompt about feature A", "tag1, tag2"),
                new ExchangePanel("10:05", "Response summary A", "tag2")
        ));

        ConversationPanel c2 = new ConversationPanel("Conversation B", List.of(
                new ExchangePanel("11:00", "Another prompt", "tagX"),
                new ExchangePanel("11:05", "Another response", "tagY"),
                new ExchangePanel("11:10", "Follow up question", "tagZ")
        ));

        container.add(c1);
        container.add(Box.createRigidArea(new Dimension(0, 10)));
        container.add(c2);

        JScrollPane scrollPane = new JScrollPane(container);
        frame.setContentPane(scrollPane);

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
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new FileReader(selected))) {
                String line;
                for (int i = 0; i < 10 && (line = reader.readLine()) != null; i++) {
                    sb.append(line).append(System.lineSeparator());
                }
            } catch (IOException ex) {
                JOptionPane.showMessageDialog(parent, "Error reading file: " + ex.getMessage(),
                        "Read Error", JOptionPane.ERROR_MESSAGE);
                return;
            }

            JTextArea area = new JTextArea(sb.toString(), 20, 60);
            area.setEditable(false);
            area.setCaretPosition(0);
            JScrollPane scrollPane = new JScrollPane(area);
            JOptionPane.showMessageDialog(parent, scrollPane, "File Preview",
                    JOptionPane.INFORMATION_MESSAGE);
        }
    }
}
